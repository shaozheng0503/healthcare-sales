package com.healthcare.sales.config;

import com.healthcare.sales.interceptor.AuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

/**
 * Web MVC 配置：跨域 + 拦截器
 */
@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final AuthInterceptor authInterceptor;

    /** 跨域配置（前端 localhost:3000 访问后端 localhost:8080） */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    /**
     * 注册拦截器
     * 全局拦截，白名单放行公开接口
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                        // 登录注册
                        "/user/login",
                        "/user/register",
                        // 商品浏览（消费者无需登录）
                        "/product/page",
                        // 分类树（首页展示）
                        "/category/tree",
                        "/category/list",
                        // 科普文章浏览
                        "/article/page",
                        // 文件访问
                        "/upload/**",
                        // 错误页
                        "/error"
                );
    }

    /** 静态资源映射：上传的图片可直接通过URL访问 */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/upload/**")
                .addResourceLocations("file:" + System.getProperty("user.dir") + "/upload/");
    }
}
