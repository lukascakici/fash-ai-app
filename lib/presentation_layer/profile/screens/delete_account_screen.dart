import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../backend_layer/main/navigation/routes/name.dart';
import '../../../global/constants/app_constant.dart';
import '../../../global/global.dart';
import '../../../global/widgets/toast_info.dart';
import '../widgets/account_list_item.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  void _confirmAccountDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("delete_account".tr()),
          content: Text(
            "delete_account_description".tr(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("cancel".tr()),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount(context);
              },
              child: Text(
                "delete".tr(),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .delete();

      await currentUser?.delete();

      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pop(); // Close the dialog
      await Global.storageServices.remove(AppConstants.STORAGE_USER_TOKEN_KEY);
      Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login, (Route<dynamic> route) => false);

      showToast(msg: 'Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showToast(msg: 'Please re-authenticate and try again.');
      } else {
        showToast(msg: 'Error deleting account: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: BuildAppBar(
      //   appBarTitle: "account_settings".tr(),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
      body: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.r)),
              child: AccountListItem(
                title: "delete_account".tr(),
                iconPath: 'assets/icons/delete.svg',
                onTap: () {
                  _confirmAccountDeletion(context);
                },
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
