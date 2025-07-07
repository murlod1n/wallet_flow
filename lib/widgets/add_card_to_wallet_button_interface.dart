import 'package:flutter/widgets.dart';

abstract class AddCardToWalletButtonInterface extends StatelessWidget {
  const AddCardToWalletButtonInterface({super.key, required this.onPressed, this.borderRadius});

  final VoidCallback? onPressed;
  final BorderRadius? borderRadius;

}
