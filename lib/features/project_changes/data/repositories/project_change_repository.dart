import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/project_change.dart';
class ProjectChangeRepository {
 final _db=FirebaseFirestore.instance;
 CollectionReference<Map<String,dynamic>> get _c=>_db.collection('project_changes');
 Stream<List<ProjectChange>> stream(String projectId)=>_c.where('projectId',isEqualTo:projectId).snapshots().map((s)=>s.docs.map(ProjectChange.fromFirestore).toList()..sort((a,b)=>b.createdAt.compareTo(a.createdAt)));
 Future<void> save(ProjectChange c) async {final doc=c.id.isEmpty?_c.doc():_c.doc(c.id); await doc.set(c.copyWith(id:doc.id,updatedAt:DateTime.now()).toFirestore());}
 Future<void> delete(String id)=>_c.doc(id).delete();
}
