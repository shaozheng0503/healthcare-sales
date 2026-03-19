package com.healthcare.sales.interceptor;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.sales.common.result.Result;
import com.healthcare.sales.utils.JwtUtil;
import com.healthcare.sales.utils.UserContext;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.util.StringUtils;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Arrays;
import java.util.List;

/**
 * JWT 认证拦截器
 * - 严格认证路径：必须携带有效token
 * - 可选认证路径：有token则解析，无token也放行（如商品详情、文章详情）
 */
@Component
@RequiredArgsConstructor
public class AuthInterceptor implements HandlerInterceptor {

    private final JwtUtil      jwtUtil;
    private final ObjectMapper objectMapper;

    private static final AntPathMatcher pathMatcher = new AntPathMatcher();

    /** 可选认证路径：GET请求时无需登录也可访问 */
    private static final List<String> OPTIONAL_AUTH_PATTERNS = Arrays.asList(
            "/product/*",
            "/article/*"
    );

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String authHeader = request.getHeader("Authorization");
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();  // "/api"
        String path = uri.startsWith(contextPath) ? uri.substring(contextPath.length()) : uri;
        String method = request.getMethod();

        // 尝试解析token
        boolean tokenValid = false;
        if (StringUtils.hasText(authHeader) && authHeader.startsWith("Bearer ")) {
            try {
                Claims claims = jwtUtil.parseToken(authHeader.substring(7));
                Long    userId = Long.valueOf(claims.getSubject());
                Integer role   = claims.get("role", Integer.class);
                UserContext.set(userId, role);
                tokenValid = true;
            } catch (JwtException | IllegalArgumentException ignored) {
                // token无效，继续判断是否需要强制认证
            }
        }

        if (tokenValid) {
            return true;
        }

        // 检查是否为可选认证路径（GET请求不强制登录）
        if ("GET".equalsIgnoreCase(method)) {
            for (String pattern : OPTIONAL_AUTH_PATTERNS) {
                if (pathMatcher.match(pattern, path)) {
                    return true;  // 无token也放行
                }
            }
        }

        // 其他需要认证的路径，token无效则返回401
        writeUnauth(response);
        return false;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        UserContext.clear();
    }

    private void writeUnauth(HttpServletResponse response) throws Exception {
        response.setStatus(401);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(objectMapper.writeValueAsString(Result.error(401, "请先登录")));
    }
}
