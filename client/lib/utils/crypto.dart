// import 'package:encrypt/encrypt.dart' as encrypt;
//
// class AES {
//   static String encode(String key, String text,
//       {encrypt.AESMode mode = encrypt.AESMode.cbc}) {
//     final k = encrypt.Key.fromUtf8(key);
//     final iv = encrypt.IV.fromUtf8(String.fromCharCodes([
//       0x00,
//       0x01,
//       0x02,
//       0x03,
//       0x04,
//       0x05,
//       0x06,
//       0x07,
//       0x08,
//       0x09,
//       0x0a,
//       0x0b,
//       0x0c,
//       0x0d,
//       0x0e,
//       0x0f
//     ]));
//     return encrypt.Encrypter(encrypt.AES(k, mode: mode, padding: "PKCS7"))
//         .encrypt(text, iv: iv)
//         .base64;
//   }
//
//   static String decode(String key, String text,
//       {encrypt.AESMode mode = encrypt.AESMode.cbc}) {
//     final k = encrypt.Key.fromUtf8(key);
//     final iv = encrypt.IV.fromUtf8(String.fromCharCodes([
//       0x00,
//       0x01,
//       0x02,
//       0x03,
//       0x04,
//       0x05,
//       0x06,
//       0x07,
//       0x08,
//       0x09,
//       0x0a,
//       0x0b,
//       0x0c,
//       0x0d,
//       0x0e,
//       0x0f
//     ]));
//     return encrypt.Encrypter(encrypt.AES(k, mode: mode, padding: "PKCS7"))
//         .decrypt64(text, iv: iv);
//   }
// }
