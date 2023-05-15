class ItemViewModel {
  int id;
  String name;
  String? name2;
  int? unitId; // bura nullable göstermiyor
  String unitCode;
  String? itemType; // bura nullable göstermiyor
  int? typeId; // bura nullable göstermiyor
  String? barcode;
  String? tradeMark;
  double? unitPrice;
  double? unitPrice2;
  double? unitPrice3;
  double? pakettekiMiktar;
  double? agirlikGr;
  double? taxRate;
  double? taxRateAlis;
  double? stokAdeti;
  String? renk;
  int? renkId;
  int? beden;
  int? varyantId;
  double? varyantMiktar;
  String? mainImageUrl;
  String? mainThumImageUrl;
  // ---

  late final Map<String, dynamic> _rawData;

  ItemViewModel({
    required this.id,
    required this.name,
    this.name2,
    required this.unitId,
    required this.unitCode,
    required this.itemType,
    required this.typeId,
    this.barcode,
    this.tradeMark,
    this.unitPrice,
    this.unitPrice2,
    this.unitPrice3,
    this.pakettekiMiktar,
    this.agirlikGr,
    this.taxRate,
    this.taxRateAlis,
    this.stokAdeti,
    this.renk,
    this.renkId,
    this.beden,
    this.varyantId,
    this.varyantMiktar,
    this.mainImageUrl,
    this.mainThumImageUrl,
    required Map<String, dynamic> rawData,
  }) {
    _rawData = rawData;
  }

  factory ItemViewModel.fromJson(Map<String, dynamic> json) {
    return ItemViewModel(
      id: json["ID"],
      name: json["Name"],
      name2: json["Name2"],
      unitId: json["UnitID"],
      unitCode: json["UnitCode"],
      itemType: json["ItemType"],
      typeId: json["TypeID"],
      barcode: json["Barcode"],
      tradeMark: json["TradeMark"],
      unitPrice: json["UnitPrice"],
      unitPrice2: json["UnitPrice2"],
      unitPrice3: json["UnitPrice3"],
      pakettekiMiktar: json["PakettekiMiktar"],
      agirlikGr: json["AgirlikGr"],
      taxRate: json["TaxRate"],
      taxRateAlis: json["TaxRateAlis"],
      stokAdeti: json["StokAdeti"],
      renk: json["Renk"],
      renkId: json["RenkID"],
      beden: json["Beden"],
      varyantId: json["VaryantID"],
      varyantMiktar: json["VaryantMiktar"],
      mainImageUrl: json["MainImageUrl"],
      mainThumImageUrl: json["MainThumbImageUrl"],
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return _rawData;
  }
}
