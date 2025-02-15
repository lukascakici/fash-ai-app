import 'package:fash_ai/presentation_layer/ai_chat/widgets/logo_with_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildMessage(Map<String, String> message, BuildContext context) {
  final isUserMessage = message["sender"] == "user";
  final messageText = message["text"] ?? "";

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUserMessage) LogoWithText(context: context),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              constraints: BoxConstraints(maxWidth: 230.w),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: MarkdownBody(
                data: messageText,
                styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: Theme.of(context).textTheme.bodyMedium,
                  strong: Theme.of(context).textTheme.bodyMedium,
                  listBullet: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  blockSpacing: 8.0.h,
                  listIndent: 16.0,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
