class User {
  int? id;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? token;
  String? role;
  String? avatar;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.token,
    this.role,
    this.avatar,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
    final user = data['user'] is Map<String, dynamic>
      ? data['user'] as Map<String, dynamic>
      : data;
    return User(
      id: user['id'] ?? json['id'],
      name: user['name'] ?? json['name'],
      email: user['email'] ?? json['email'],
      phone: user['phone'] ?? json['phone'],
      password: user['password'] ?? json['password'],
      token: json['token'] ?? data['token'],
      role: user['role'] ?? json['role'],
      avatar:
          user['avatar'] ??
          user['profile_image'] ??
          json['avatar'] ??
          json['profile_image'],
    );
  }
}

User users = User(
  name: "Seang Leangsim",
  email:
      "https://scontent.fpnh5-4.fna.fbcdn.net/v/t39.30808-6/480817907_1020905033185733_4486874781651635030_n.jpg?stp=dst-jpg_tt6&cstp=mx960x1280&ctp=s960x1280&_nc_cat=101&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeEEDb4ZEQFa9uHYs3Nxh6W12zK2oHFEpgTbMragcUSmBBNPAY4HSgl8xa6XJjKSAK_V1Is9_pmPw0-eNpW0sYW6&_nc_ohc=obT7gHZF1V0Q7kNvwGzqXYC&_nc_oc=AdrgvMnuR4MmsvFJRuijBlIvMGjo1tGgguoIqE94Dx_dN1L8262U75rzg_9zozmgBPo&_nc_zt=23&_nc_ht=scontent.fpnh5-4.fna&_nc_gid=T8v8-MkZCBQTaBEo43T9Og&_nc_ss=7b2a8&oh=00_Af-XhKEKGGeJ_lPxdJA8HVB0QowfBh8GIDUKcUpkXfkZyQ&oe=6A36E32D",
  password: "Phnom Penh, Cambodia",
);
