// ignore_for_file: curly_braces_in_flow_control_structures

class StockFicheList {
  int id;
  String? ficheNo;
  int? type;
  String? typeName;
  int? branch;
  String? branchName;
  String? ozelKod;
  int? status;
  String? statusName;
  String? notes;
  String? transDate;
  int? stockWareHouseID;
  String? stockWareHouseName;
  int? destStockWareHouseID;
  String? destStockWareHouseName;

  StockFicheList({
    required this.id,
    this.ficheNo,
    this.type,
    this.typeName,
    this.branch,
    this.branchName,
    this.ozelKod,
    this.status,
    this.statusName,
    this.notes,
    this.transDate,
    this.stockWareHouseID,
    this.stockWareHouseName,
    this.destStockWareHouseID,
    this.destStockWareHouseName,
  });

  factory StockFicheList.fromJson(Map<String, dynamic> json) {
    return StockFicheList(
      id: json['ID'],
      ficheNo: json['FicheNo'],
      type: json['Type'],
      typeName: json['TypeName'],
      branch: json['Branch'],
      branchName: json['BranchName'],
      ozelKod: json['OzelKod'],
      status: json['Status'],
      statusName: json['StatusName'],
      notes: json['Notes'],
      transDate: json['TransDate'],
      stockWareHouseID: json['StockWareHouseID'],
      stockWareHouseName: json['StockWareHouseName'],
      destStockWareHouseID: json['DestStockWareHouseID'],
      destStockWareHouseName: json['DestStockWareHouseName'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {"ID": id};
    if (ficheNo != null) data["FicheNo"] = ficheNo;
    if (type != null) data["Type"] = type;
    if (typeName != null) data["TypeName"] = typeName;
    if (branch != null) data["Branch"] = branch;
    if (branchName != null) data["BranchName"] = branchName;
    if (ozelKod != null) data["OzelKod"] = ozelKod;
    if (status != null) data["Status"] = status;
    if (statusName != null) data["StatusName"] = statusName;
    if (notes != null) data["Notes"] = notes;
    if (transDate != null) data["TransDate"] = transDate;
    if (stockWareHouseID != null) data["StockWareHouseID"] = stockWareHouseID;
    if (stockWareHouseName != null)
      data["StockWareHouseName"] = stockWareHouseName;
    if (destStockWareHouseID != null)
      data["DestStockWareHouseID"] = destStockWareHouseID;
    if (destStockWareHouseName != null)
      data["DestStockWareHouseName"] = destStockWareHouseName;
    return data;
  }
}
