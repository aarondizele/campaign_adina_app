import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../model/model.dart';

class SelectDistrict extends StatefulWidget {
  final ValueChanged<Map<String, String>> onSelectValues;

  const SelectDistrict({Key key, @required this.onSelectValues}) : super(key: key);
  @override
  _SelectDistrictState createState() => _SelectDistrictState();
}

class _SelectDistrictState extends State<SelectDistrict> {
  Messaging message;

  List kinshasa = ['Funa', 'Lukunga', 'Mont Amba', 'Tshangu'];
  List maniema = ['Kabambare', 'Kailo', 'Kasongo', 'Kibombo', 'Lubutu', 'Pangi', 'Punia', 'Alungili', 'Kasuku', 'Mikelenge'];
  List nordkivu = ['Beni', 'Lubero', 'Masisi', 'Nyiragongo', 'Rutshuru', 'Walike', 'Bungulu', 'Ruwenzori', 'Muhekera', 'Goma', 'Karisimbi', 'Bulengera', 'Kimemi', 'Mususa', 'Vutumba'];
  List sudkivu = ['Fizi', 'Idjwi', 'Kabare', 'Kalehe', 'Mwenga', 'Shabunda', 'Uvira', 'Walungu'];
  List maindombe = ['Disasi', 'Basoko', 'Mayoyo', 'Bolobo', 'Kwamouth', 'Mushie', 'Yumbi', 'Bokoro', 'Inongo', 'Kiri', 'Kutu', 'Nioki', 'Oshwe'];
  List kongocentral = ['Lukusa', 'Seke-Banza', 'Tshela', 'Matadi', 'Nzanza', 'Mvunzi', 'Kasangulu', 'Kimvula', 'Madimba', 'Luozi', 'Mbanza-Ngungu', 'Songololo'];
  List basuele = ['Aketi', 'Ango', 'Bambesa', 'Bondo', 'Buta', 'Gwane', 'Poko'];
  List tshuapa = ['Befale', 'Boende', 'Bokungu', 'Djolu', 'Ikela', 'Monkoto'];
  List tshopo = ['Bafwasende', 'Banalia', 'Basoko', 'Isangi', 'Opala', 'Ubundu', 'Yahuma', 'Kabondo', 'Kisangani', 'Lubunga', 'Makiso', 'Mangobo', 'Tshopo'];
  List kasaioriental = ['Kabeya-Kamwanga', 'Katanda', 'Luhatahata', 'Miabi', 'Tshilenge'];
  List kasaioccidental = ['Dibumba I', 'Dibumba II', 'Kanzala', 'Mabondo', 'Mbumba', 'Dekese', 'Ilebo', 'Kamonia', 'Luebo', 'Mweka', 'Tshikapa'];
  List tanganyika = ['Kabalo', 'Kalemie', 'Kongolo', 'Manono', 'Moba', 'Nyunzu'];
  List sudubangi = ['Budjiala', 'Gemena', 'Kungu', 'Libenge', 'Nzulu', 'Wango'];
  List mongala = ['Bumba', 'Bongandanga', 'Lisala'];
  List lomani = ['Bondoyi', 'Musadi', 'Mwene Ditu', 'Gandajika', 'Kabinda', 'Kamiji', 'Lubao', 'Luila'];
  List nordubangi = ['Businga', 'Bosobolo', 'Mobayi Mbongo', 'Yakoma', 'Gbadolite', 'Molegbe', 'Nganza'];
  List sankuru = ['Katako Kombe', 'Kole', 'Lodja', 'Lomela', 'Lubefu', 'Lusambo', 'Bipemba', 'Dibindi', 'Diulu', 'Kanshi', 'Muya'];
  List equateur = ['Mbandaka', 'Wangata', 'Basankusu', 'Bikoro', 'Bolomba', 'Bomongo', 'Ingembe', 'Lukolela', 'Makanza'];
  List lulua = ['Demba', 'Dibaya', 'Dimbelenge', 'Kazumba', 'Luiza', 'Kananga', 'Katoka', 'Lukonga', 'Ndesha', 'Nganza'];
  List hautkatanga = ['Annexe', 'Kamalondo', 'Kampemba', 'Katuba', 'Kenya', 'Lubumbashi', 'Rwashi', 'Panda', 'Kikula', 'Likasi', 'Tshituru', 'Kambove', 'Kasenga', 'Kipushi', 'Mitwaba', 'Pweto', 'Sakania'];
  List lualaba = ['Dilolo', 'Kapanga', 'Sandoa', 'Lubudi', 'Mutshatsha', 'Dilala', 'Manika'];
  List kwilu = ['Bagata', 'Bulungu', 'Eolo', 'Gungu', 'Idiofa', 'Kalo', 'Kikwit', 'Kilembe', 'Mangai', 'Masi-Manimba', 'Musenge', 'Munene', 'Nkara', 'Sedzo', 'Zaba', 'Kazamba', 'Lukumi', 'Lukolela', 'Nzida'];
  List kwango = ['Feshi', 'Kahemba', 'Kasongo-Lunda', 'Kenge', 'Kisandji', 'Popokabaka'];
  List ituri = ['Aru', 'Djugu', 'Irumu', 'Mahagi', 'Mambasa'];
  List hautuele = ['Dungu', 'Faradje', 'Niangara', 'Rungu', 'Wamba', 'Watsa'];
  List hautlomani = ['Bukama', 'Kabongo', 'Kamina', 'Kanyama', 'Malemba-Nkulu'];

  String selectedDistrict = '';
  String selectedProvince = '';

  List _cities = ['VILLE 1', 'VILLE 2', 'VILLE 3', 'VILLE 4'];


  // Widget expansionTile(String province, List<dynamic> districts) {
  //   final _lists = districts.map((v) => getDistrict(v, province)).toList();
  //   return ExpansionTile(
  //     title: getProvince(province),
  //     children: _lists,
  //   );
  // }

  // Widget getProvince(String province) {
  //   return Text(province.toUpperCase(), style: Theme.of(context).textTheme.body1,);
  // }

  // Widget getDistrict(String district, String province) {
  //   return Column(
  //     children: <Widget>[
  //       RadioListTile(
  //         dense: true,
  //         title: Text(district.toUpperCase()),
  //           groupValue: selectedDistrict,
  //           value: district,
  //           onChanged: (value) async {
  //             Map<String, String> _values = {
  //               'district': district,
  //               'province': province
  //             };
  //             widget.onSelectValues(_values);
  //             Navigator.of(context).pop();
  //           },
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    TextStyle primaryTextColor = Theme.of(context).textTheme.button.copyWith(
        color: Theme.of(context).primaryColor, fontWeight: FontWeight.w300);

    return AlertDialog(
      title: Text('Choisissez une ville', style: Theme.of(context).textTheme.subhead.copyWith(fontFamily: 'Product Sans')),
      titlePadding: EdgeInsets.only(right: 0.0, left: 16.0, top: 16.0, bottom: 8.0),
      contentPadding:
          EdgeInsets.only(right: 0.0, left: 0.0, top: 8.0, bottom: 0.0),
      content: ListView(
        children: _cities.map((city) {
          return  RadioListTile(
          dense: true,
          title: Text(city.toUpperCase()),
            groupValue: selectedDistrict,
            value: city,
            onChanged: (value) async {
              Map<String, String> _values = {
                'district': city,
                'province': city
              };
              widget.onSelectValues(_values);
              Navigator.of(context).pop();
            },
        );
        }).toList(),
        // children: <Widget>[
          // expansionTile('Kinshasa', kinshasa),
          // expansionTile('Kongo Central', kongocentral),
          // expansionTile('Lualaba', lualaba),
          // expansionTile('Nord Kivu', nordkivu),
          // expansionTile('Sud Kivu', sudkivu),
          // expansionTile('Kwilu', kwilu),
          // expansionTile('Kwango', kwango),
          // expansionTile('Maniema', maniema),
          // expansionTile('Mai-Ndombe', maindombe),
          // expansionTile('Bas-Uele', basuele),
          // expansionTile('Tshuapa', tshuapa),
          // expansionTile('Tshopo', tshopo),
          // expansionTile('Kasai Oriental', kasaioriental),
          // expansionTile('Kasai Occidental', kasaioccidental),
          // expansionTile('Tanganyika', tanganyika),
          // expansionTile('Sub Ubangi', sudubangi),
          // expansionTile('Mongala', mongala),
          // expansionTile('Lomani', lomani),
          // expansionTile('Nord Ubangi', nordubangi),
          // expansionTile('Sankuru', sankuru),
          // expansionTile('Equateur', equateur),
          // expansionTile('Lulua', lulua),
          // expansionTile('Haut Katanga', hautkatanga),
          // expansionTile('Lualaba', lualaba),
          // expansionTile('Ituri', ituri),
          // expansionTile('Haut Uele', hautuele),
          // expansionTile('Haut Lomani', hautlomani),
        // ]
      ),
      actions: <Widget>[
        FlatButton(
          color: Colors.white,
          child: Text('ANNULER', style: primaryTextColor,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
