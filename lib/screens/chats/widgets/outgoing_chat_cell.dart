import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:flutter/material.dart';

class OutgoingChatCell extends StatefulWidget {
  const OutgoingChatCell({super.key, required this.item});

  final MessageData item;

  @override
  State<OutgoingChatCell> createState() => _OutgoingChatCellState();
}

class _OutgoingChatCellState extends State<OutgoingChatCell> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.outgoingChatCell,
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          margin: EdgeInsets.only(top: 5, bottom: 5),
          // width: MediaQuery.of(context).size.width * 70 / 100,
          constraints: BoxConstraints(
            minWidth: 100.0, // Minimum width of 100 logical pixels
            maxWidth:
                MediaQuery.of(context).size.width *
                85 /
                100, // Maximum width of 300 logical pixels
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.message!,
                style: ConstantStyles.medium.copyWith(fontSize: 16),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  chatFormatTimeAMPM(widget.item.timestamp),
                  textAlign: TextAlign.right,
                  style: ConstantStyles.medium.copyWith(
                    fontSize: 13,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
