package com.healthcare.sales.utils;

/**
 * 当前登录用户上下文（ThreadLocal）
 */
public class UserContext {

    private static final ThreadLocal<Long>    USER_ID   = new ThreadLocal<>();
    private static final ThreadLocal<Integer> USER_ROLE = new ThreadLocal<>();

    public static void set(Long userId, Integer role) {
        USER_ID.set(userId);
        USER_ROLE.set(role);
    }

    public static Long getUserId() {
        return USER_ID.get();
    }

    public static Integer getRole() {
        return USER_ROLE.get();
    }

    public static boolean isAdmin() {
        return Integer.valueOf(0).equals(USER_ROLE.get());
    }

    public static boolean isBackend() {
        Integer role = USER_ROLE.get();
        return Integer.valueOf(0).equals(role) || Integer.valueOf(1).equals(role);
    }

    public static void clear() {
        USER_ID.remove();
        USER_ROLE.remove();
    }
}
