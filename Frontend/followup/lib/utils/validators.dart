// 表单验证工具类
class Validators {
  // 验证用户名
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 3) {
      return '用户名至少3个字符';
    }
    if (value.length > 20) {
      return '用户名最多20个字符';
    }
    return null;
  }

  // 验证密码
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少6个字符';
    }
    return null;
  }

  // 验证标题
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入标题';
    }
    if (value.length > 100) {
      return '标题最多100个字符';
    }
    return null;
  }

  // 验证文本内容
  static String? validateTextContent(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入内容';
    }
    if (value.length > 5000) {
      return '内容最多5000个字符';
    }
    return null;
  }

  // 验证日期
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return '请选择日期';
    }
    return null;
  }
}
