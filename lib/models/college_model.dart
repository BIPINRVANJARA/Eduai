class CollegeModel {
  final String id;
  final String name;
  final String shortName;
  final String code;
  final String city;
  final String state;
  final String address;
  final double rating;
  final int studentCount;
  final bool admissionsOpen;
  final List<String> tags;
  final Map<String, String> faqs;
  final String contactPhone;
  final String contactEmail;
  final String website;

  const CollegeModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.code,
    required this.city,
    required this.state,
    required this.address,
    required this.rating,
    required this.studentCount,
    required this.admissionsOpen,
    required this.tags,
    required this.faqs,
    required this.contactPhone,
    required this.contactEmail,
    required this.website,
  });
}
