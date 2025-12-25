// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class StarRatingFormField extends FormField<int> {
  StarRatingFormField({
    super.key,
    super.onSaved,
    super.validator,
    int super.initialValue = 0,
    AutovalidateMode autovalidate = AutovalidateMode.disabled,
  }) : super(
         autovalidateMode: autovalidate,
         builder: (FormFieldState<int> state) {
           return Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               for (int i = 1; i <= 5; i++)
                 InkWell(
                   onTap: () => state.didChange(i),
                   borderRadius: BorderRadius.circular(10),
                   child: Icon(
                     state.value! >= i
                         ? Icons.star_rounded
                         : Icons.star_outline_rounded,
                   ),
                 ),
             ],
           );
         },
       );
}
