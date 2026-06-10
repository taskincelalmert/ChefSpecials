import 'dart:async';
import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentProvider extends ChangeNotifier {
  final CommentService _service;

  CommentProvider({CommentService? commentService})
      : _service = commentService ?? CommentService();

  List<Comment> _comments = [];
  StreamSubscription? _subscription;

  List<Comment> get comments => _comments;

  List<Comment> get topLevelComments =>
      _comments.where((c) => c.parentCommentId == null).toList();

  List<Comment> repliesFor(String commentId) =>
      _comments.where((c) => c.parentCommentId == commentId).toList();

  int replyCount(String commentId) => repliesFor(commentId).length;

  void listenToComments(String recipeId) {
    _subscription?.cancel();
    _subscription = _service.getCommentsStream(recipeId).listen(
      (comments) {
        _comments = comments;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('CommentProvider stream error: $e');
      },
    );
  }

  Future<void> addComment(Comment comment) async {
    await _service.addComment(comment);
  }

  Future<void> updateCommentText({
    required String commentId,
    required String recipeId,
    required String newText,
    required int newStars,
  }) async {
    await _service.updateCommentText(
      commentId: commentId,
      recipeId: recipeId,
      newText: newText,
      newStars: newStars,
    );
  }

  Future<void> deleteComment({
    required String commentId,
    required String recipeId,
  }) async {
    await _service.deleteComment(commentId: commentId, recipeId: recipeId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
