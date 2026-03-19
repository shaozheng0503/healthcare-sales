package com.healthcare.sales.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.entity.User;
import com.healthcare.sales.mapper.UserMapper;
import com.healthcare.sales.utils.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class UserServiceImpl {

    private final UserMapper            userMapper;
    private final JwtUtil               jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder;

    /** 登录 */
    public Map<String, Object> login(String username, String password) {
        User user = userMapper.selectByUsernameWithPwd(username);
        if (user == null) {
            throw BusinessException.of("用户名或密码错误");
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw BusinessException.of("用户名或密码错误");
        }
        if (user.getStatus() == 0) {
            throw BusinessException.of("账号已被禁用");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        user.setPassword(null);

        Map<String, Object> result = new HashMap<>();
        result.put("token",    token);
        result.put("userInfo", user);
        return result;
    }

    /** 注册 */
    public void register(User user) {
        Long count = userMapper.selectCount(
                new LambdaQueryWrapper<User>().eq(User::getUsername, user.getUsername()));
        if (count > 0) {
            throw BusinessException.of("用户名已存在");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setRole(2);    // 默认消费者
        user.setStatus(1);
        userMapper.insert(user);
    }

    /** 分页查询用户列表 */
    public Page<User> page(Integer pageNum, Integer pageSize, String username, Integer role) {
        Page<User> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<User>()
                .like(username != null && !username.isEmpty(), User::getUsername, username)
                .eq(role != null, User::getRole, role)
                .orderByDesc(User::getCreatedAt);
        return userMapper.selectPage(page, wrapper);
    }

    /** 更新用户信息 */
    public void update(Long userId, User user) {
        user.setId(userId);
        user.setUsername(null);   // 不允许修改用户名
        user.setRole(null);       // 不允许自行修改角色
        user.setStatus(null);     // 不允许自行修改状态

        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            // 修改密码时需验证旧密码
            if (user.getOldPassword() == null || user.getOldPassword().isEmpty()) {
                throw BusinessException.of("请输入原密码");
            }
            // 通过ID查用户名，再查带密码的记录（selectById 默认不含 password）
            User current = userMapper.selectById(userId);
            if (current == null) throw BusinessException.of("用户不存在");
            User withPwd = userMapper.selectByUsernameWithPwd(current.getUsername());
            if (!passwordEncoder.matches(user.getOldPassword(), withPwd.getPassword())) {
                throw BusinessException.of("原密码错误");
            }
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        } else {
            user.setPassword(null);
        }
        user.setOldPassword(null);  // 不持久化
        userMapper.updateById(user);
    }

    /** 根据ID查询用户信息 */
    public User getById(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) throw BusinessException.of("用户不存在");
        return user;
    }

    /** 启用/禁用 */
    public void updateStatus(Long id, Integer status) {
        User user = new User();
        user.setId(id);
        user.setStatus(status);
        userMapper.updateById(user);
    }

    /** 删除用户 */
    public void delete(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) throw BusinessException.of("用户不存在");
        if (user.getRole() == 0) throw BusinessException.of("不能删除管理员账号");
        userMapper.deleteById(id);
    }
}
