import 'package:flutter/material.dart';

class FirstCard extends StatefulWidget {
/*  final String name;
  final String phone;
  final String email;
  final String companyName;
  final String companyContact;
  final String position;
  final String department;
  final String fax;
  final String logo;*/

  const FirstCard({
    super.key,
    // required this.name,
    // required this.phone,
    // required this.email,
    // required this.companyContact,
    // required this.companyName,
    // required this.position,
    // required this.department,
    // required this.fax,
    // required this.logo
  });

  @override
  State<FirstCard> createState() => _FirstCardState();
}

class _FirstCardState extends State<FirstCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 940,
        height: 540,
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 10),),
            Divider(
            color: Color.fromRGBO(187, 212, 255, 100),
            thickness: 2,
            indent: 20,
            endIndent: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("ITDAT.",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 50,
                    color: Color.fromRGBO(187, 212, 255, 100),
                    ),
                ),
                Column(
                  children: [
                    Text("서울시 서초구 강남대로 405",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Color.fromRGBO(187, 212, 255, 100),
                        ),
                    ),
                    Text("T. 010-8082-3000",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Color.fromRGBO(187, 212, 255, 100),
                      ),
                    ),
                    Text("F. 0507-1409-0008",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Color.fromRGBO(187, 212, 255, 100),
                      ),
                    ),
                    Text("E. itdat@gmail.com",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Color.fromRGBO(187, 212, 255, 100),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Padding(padding: const EdgeInsets.only(bottom: 70)),
            Divider(
              color: Color.fromRGBO(187, 212, 255, 100),
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            Padding(padding: const EdgeInsets.only(top: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("부서",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Color.fromRGBO(187, 212, 255, 100),
                      ),
                    ),
                    Text("직책",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Color.fromRGBO(187, 212, 255, 100),
                      ),
                    ),
                  ],
                ),
                Text("이름",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 50,
                    color: Color.fromRGBO(187, 212, 255, 100),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
