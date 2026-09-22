import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectChangeStatus { waiting, approved, rejected }

class ProjectChange {
  final String id, projectId, title, comment;
  final double amount;
  final ProjectChangeStatus status;
  final DateTime createdAt, updatedAt;
  const ProjectChange({required this.id,required this.projectId,required this.title,required this.amount,required this.status,required this.comment,required this.createdAt,required this.updatedAt});
  ProjectChange copyWith({String? id,String? projectId,String? title,double? amount,ProjectChangeStatus? status,String? comment,DateTime? createdAt,DateTime? updatedAt})=>ProjectChange(id:id??this.id,projectId:projectId??this.projectId,title:title??this.title,amount:amount??this.amount,status:status??this.status,comment:comment??this.comment,createdAt:createdAt??this.createdAt,updatedAt:updatedAt??this.updatedAt);
  Map<String,dynamic> toFirestore()=>{'projectId':projectId,'title':title,'amount':amount,'status':status.name,'comment':comment,'createdAt':Timestamp.fromDate(createdAt),'updatedAt':Timestamp.fromDate(updatedAt)};
  factory ProjectChange.fromFirestore(DocumentSnapshot<Map<String,dynamic>> doc){final d=doc.data()??{};return ProjectChange(id:doc.id,projectId:d['projectId'] as String? ?? '',title:d['title'] as String? ?? '',amount:(d['amount'] as num?)?.toDouble()??0,status:ProjectChangeStatus.values.firstWhere((s)=>s.name==d['status'],orElse:()=>ProjectChangeStatus.waiting),comment:d['comment'] as String? ?? '',createdAt:d['createdAt'] is Timestamp?(d['createdAt'] as Timestamp).toDate():DateTime.now(),updatedAt:d['updatedAt'] is Timestamp?(d['updatedAt'] as Timestamp).toDate():DateTime.now());}
}
