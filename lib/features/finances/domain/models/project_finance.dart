import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectFinance {
  final String id;
  final String projectId;
  final double plannedAmount;
  final double receivedAmount;
  final double expensesAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectFinance({required this.id, required this.projectId, this.plannedAmount=0, this.receivedAmount=0, this.expensesAmount=0, required this.createdAt, required this.updatedAt});
  double get remainingAmount => plannedAmount - receivedAmount;
  double get profitAmount => receivedAmount - expensesAmount;
  ProjectFinance copyWith({String? id,String? projectId,double? plannedAmount,double? receivedAmount,double? expensesAmount,DateTime? createdAt,DateTime? updatedAt}) => ProjectFinance(id:id??this.id,projectId:projectId??this.projectId,plannedAmount:plannedAmount??this.plannedAmount,receivedAmount:receivedAmount??this.receivedAmount,expensesAmount:expensesAmount??this.expensesAmount,createdAt:createdAt??this.createdAt,updatedAt:updatedAt??this.updatedAt);
  Map<String,dynamic> toFirestore()=>{'projectId':projectId,'plannedAmount':plannedAmount,'receivedAmount':receivedAmount,'expensesAmount':expensesAmount,'createdAt':Timestamp.fromDate(createdAt),'updatedAt':Timestamp.fromDate(updatedAt)};
  factory ProjectFinance.fromFirestore(DocumentSnapshot<Map<String,dynamic>> doc){final d=doc.data()??{}; double n(dynamic v)=>v is num?v.toDouble():double.tryParse(v?.toString()??'')??0; DateTime dt(dynamic v)=>v is Timestamp?v.toDate():DateTime.now(); return ProjectFinance(id:doc.id,projectId:d['projectId'] as String? ?? '',plannedAmount:n(d['plannedAmount']),receivedAmount:n(d['receivedAmount']),expensesAmount:n(d['expensesAmount']),createdAt:dt(d['createdAt']),updatedAt:dt(d['updatedAt']));}
  static String formatMoney(double v)=>'${v.round()} ₸';
}
