// import 'dart:convert';
// import 'package:dartz/dartz.dart';
// import 'package:http/http.dart' as http;
// import 'package:tagzone/core/class/status_request.dart';
// import 'check_internet.dart';
//
// class Crud {
//   Future<Either<StatusRequest, Map>> postData(
//       String linkUrl, Map data, Map<String, String> header) async {
//     try {
//       if (await checkInternet()) {
//         var response = await http.post(
//           Uri.parse(linkUrl),
//           body: jsonEncode(data),
//           headers: header,
//         );
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           Map responseBody = jsonDecode(response.body);
//           return Right(responseBody);
//         } else {
//           return const Left(StatusRequest.serverFailure);
//         }
//       } else {
//         return const Left(StatusRequest.offlineFailure);
//       }
//     } catch (e) {
//       return const Left(StatusRequest.serverFailure);
//     }
//   }
// }
