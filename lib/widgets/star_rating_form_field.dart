// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class StarRatingFormField extends FormField<int> {
  StarRatingFormField({
    super.key,
    FormFieldSetter<int>? onSaved,
    FormFieldValidator<int>? validator,
    int initialValue = 0,
    AutovalidateMode autovalidate = AutovalidateMode.disabled,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidateMode: autovalidate,
            builder: (FormFieldState<int> state) {
              return Row(children: [
                for (int i = 1; i <= 5; i++)
                  InkWell(
                    onTap: () => state.didChange(i),
                    borderRadius: BorderRadius.circular(10),
                    child: Icon(state.value! >= i
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded),
                  ),
              ]);
            });
}
