package com.healthcare.sales.controller;

import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.common.result.Result;
import com.healthcare.sales.entity.User;
import com.healthcare.sales.service.impl.UserServiceImpl;
import com.healthcare.sales.utils.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {

    private final UserServiceImpl userService;

    /** 登录 */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        Map<String, Object> data = userService.login(body.get("username"), body.get("password"));
        return Result.success(data);
    }

    /** 注册 */
    @PostMapping("/register")
    public Result<Void> register(@RequestBody User user) {
        userService.register(user);
        return Result.success();
    }

    /** 获取当前用户信息（需登录） */
    @GetMapping("/info")
    public Result<User> info() {
        User user = userService.getById(UserContext.getUserId());
        return Result.success(user);
    }

    /** 更新个人信息（需登录） */
    @PutMapping("/update")
    public Result<Void> update(@RequestBody User user) {
        userService.update(UserContext.getUserId(), user);
        return Result.success();
    }

    /** 用户列表（仅管理员） */
    @GetMapping("/list")
    public Result<?> list(@RequestParam(defaultValue = "1") Integer page,
                          @RequestParam(defaultValue = "10") Integer size,
                          @RequestParam(required = false) String username,
                          @RequestParam(required = false) Integer role) {
        checkAdmin();
        return Result.success(userService.page(page, size, username, role));
    }

    /** 修改状态（仅管理员） */
    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id,
                                     @RequestBody Map<String, Integer> body) {
        checkAdmin();
        userService.updateStatus(id, body.get("status"));
        return Result.success();
    }

    /** 删除用户（仅管理员） */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        checkAdmin();
        userService.delete(id);
        return Result.success();
    }

    private void checkAdmin() {
        if (!UserContext.isAdmin()) {
            throw BusinessException.of("无权限操作");
        }
    }
}
