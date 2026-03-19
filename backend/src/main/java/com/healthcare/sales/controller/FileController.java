package com.healthcare.sales.controller;

import com.healthcare.sales.common.exception.BusinessException;
import com.healthcare.sales.common.result.Result;
import com.healthcare.sales.utils.UserContext;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * 文件上传（商品图片、文章封面等）
 */
@RestController
@RequestMapping("/file")
public class FileController {

    @Value("${server.port:8080}")
    private int serverPort;

    /** 上传图片 */
    @PostMapping("/upload")
    public Result<Map<String, String>> upload(@RequestParam("file") MultipartFile file) {
        if (!UserContext.isBackend()) {
            throw BusinessException.of("无权限操作");
        }
        if (file.isEmpty()) {
            throw BusinessException.of("请选择文件");
        }

        // 校验文件类型
        String originalName = file.getOriginalFilename();
        int dotIndex = (originalName != null) ? originalName.lastIndexOf(".") : -1;
        String suffix = (dotIndex >= 0) ? originalName.substring(dotIndex).toLowerCase() : "";
        if (!".jpg".equals(suffix) && !".jpeg".equals(suffix) && !".png".equals(suffix)
                && !".gif".equals(suffix) && !".webp".equals(suffix)) {
            throw BusinessException.of("仅支持 jpg/png/gif/webp 格式图片");
        }

        // 校验文件大小（最大5MB）
        if (file.getSize() > 5 * 1024 * 1024) {
            throw BusinessException.of("图片大小不能超过5MB");
        }

        // 按日期分目录存放
        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String fileName = UUID.randomUUID().toString().replace("-", "") + suffix;

        String uploadDir = System.getProperty("user.dir") + "/upload/" + datePath;
        File dir = new File(uploadDir);
        if (!dir.exists() && !dir.mkdirs()) {
            throw BusinessException.of("创建上传目录失败");
        }

        try {
            file.transferTo(new File(dir, fileName));
        } catch (IOException e) {
            throw BusinessException.of("文件上传失败");
        }

        // 返回可访问的URL路径
        String url = "/api/upload/" + datePath + "/" + fileName;

        Map<String, String> data = new HashMap<>();
        data.put("url", url);
        data.put("name", originalName);
        return Result.success(data);
    }
}
