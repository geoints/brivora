import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/project_change_repository.dart';
import '../../domain/models/project_change.dart';
class ProjectChangeProvider extends ChangeNotifier {
 final _repo=ProjectChangeRepository(); List<ProjectChange> _items=[]; StreamSubscription? _sub; bool loading=false; String? error;
 List<ProjectChange> get items=>List.unmodifiable(_items);
 double get approvedTotal=>_items.where((x)=>x.status==ProjectChangeStatus.approved).fold(0,(s,x)=>s+x.amount);
 void listen(String projectId){_sub?.cancel();loading=true;notifyListeners();_sub=_repo.stream(projectId).listen((v){_items=v;loading=false;notifyListeners();},onError:(e){error=e.toString();loading=false;notifyListeners();});}
 Future<void> save(ProjectChange c) async {try{await _repo.save(c);}catch(e){error=e.toString();notifyListeners();rethrow;}}
 Future<void> delete(String id)=>_repo.delete(id);
 @override void dispose(){_sub?.cancel();super.dispose();}
}
