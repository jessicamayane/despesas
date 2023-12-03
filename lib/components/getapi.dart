import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> getTemperatureData() async {
  try {
    var url = Uri.parse(
        'https://weather.contrateumdev.com.br/api/weather/city/?city=palhoca');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      
      return data;
    } else {
      throw Exception('Falha ao carregar os dados da API');
    }
  } catch (error) {
    throw Exception('Erro na chamada da API: $error');
  }
}

// Future<String> getMinTemperatureData() async {
//   try {
//     var url = Uri.parse(
//         'https://weather.contrateumdev.com.br/api/weather/city/?city=palhoca');
//     var response = await http.get(url);

//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
      
//       return "${data["main"]["temp_min"]}°C";
//     } else {
//       throw Exception('Falha ao carregar os dados da API');
//     }
//   } catch (error) {
//     throw Exception('Erro na chamada da API: $error');
//   }
// }

// Future<String> getMaxTemperatureData() async {
//   try {
//     var url = Uri.parse(
//         'https://weather.contrateumdev.com.br/api/weather/city/?city=palhoca');
//     var response = await http.get(url);

//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
      
//       return "${data["main"]["temp_max"]}°C";
//     } else {
//       throw Exception('Falha ao carregar os dados da API');
//     }
//   } catch (error) {
//     throw Exception('Erro na chamada da API: $error');
//   }
// }