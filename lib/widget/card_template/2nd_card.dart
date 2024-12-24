import 'package:flutter/material.dart';

class SecondCard extends StatelessWidget {

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController companyNameController;
  final TextEditingController companyNumberController;
  final TextEditingController positionController;
  final TextEditingController departmentController;
  final TextEditingController faxController;
  final TextEditingController logoController;

  const SecondCard({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.companyNameController,
    required this.companyNumberController,
    required this.positionController,
    required this.departmentController,
    required this.faxController,
    required this.logoController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // 회사 로고
            if (logoController.text.isNotEmpty)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(logoController.text),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (logoController.text.isNotEmpty) const SizedBox(width: 16),
            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    nameController.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    positionController.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Department: ${departmentController.text}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const Divider(),
                  Text(
                    "Phone: ${phoneController.text}",
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    "Email: ${emailController.text}",
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    "Fax: ${faxController.text}",
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    "Company: ${companyNameController.text} (${companyNumberController.text})",
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
