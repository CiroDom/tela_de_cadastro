import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tela_de_cadastro/components/contact_tile.dart';

import '../../res/strings.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key, required this.themeChange});

  final VoidCallback themeChange;

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final birthDateFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final termsFocusNode = FocusNode(descendantsAreFocusable: false);
  final birthDateController = TextEditingController();
  final userNameFocusNome = FocusNode();
  bool obscureText = true;
  bool emailChecked = true;
  bool phoneChecked = true;
  bool aceptedTerms = false;

  final emailRegex = RegExp(
      r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp('r[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);

    return Form(
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(Strings.appName),
            actions: [
              IconButton(
                onPressed: widget.themeChange,
                icon: Icon(currentTheme.brightness == Brightness.light
                    ? Icons.dark_mode
                    : Icons.light_mode),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView(
              children: [
                buildHeader(Strings.header),
                TextFormField(
                  focusNode: userNameFocusNome,
                  decoration: buildInputDecoration(Strings.userName),
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validatorEmptyField,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: buildInputDecoration(Strings.password).copyWith(
                    helperText: Strings.passwordHelper,
                    suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() {
                              obscureText = !obscureText;
                            })),
                  ),
                  textInputAction: TextInputAction.next,
                  obscureText: obscureText,
                  inputFormatters: [LengthLimitingTextInputFormatter(16)],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: passwordValidator,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: buildInputDecoration(Strings.email),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: emailValidator,
                ),
                const SizedBox(
                  height: 10,
                ),
                buildHeader(Strings.persInfoHeader),
                TextFormField(
                    decoration: buildInputDecoration(Strings.fullName),
                    textInputAction: TextInputAction.next),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Focus(
                        focusNode: birthDateFocusNode,
                        descendantsAreFocusable: false,
                        onFocusChange: (focused) => showBirthDate(),
                        child: TextFormField(
                          decoration: buildInputDecoration(Strings.birthDate),
                          textInputAction: TextInputAction.next,
                          readOnly: true,
                          controller: birthDateController,
                          onTap: showBirthDate,
                          validator: validatorEmptyField,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        flex: 5,
                        child: TextFormField(
                          focusNode: phoneFocusNode,
                          decoration: buildInputDecoration(Strings.phoneNumber),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [phoneMask],
                          validator: phoneValidator,
                        )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ContactTile(
                  title: Strings.email,
                  contactIcon: Icons.email,
                  value: emailChecked,
                  onChanged: ((value) => setState(() => value = !emailChecked)),
                ),
                ContactTile(
                  title: Strings.phone,
                  contactIcon: Icons.phone,
                  value: phoneChecked,
                  onChanged: ((value) => setState(() => value = !phoneChecked)),
                ),
                FormField(
                  validator: (_) {
                    if (!aceptedTerms) {
                      return Strings.notAceptedTerms;
                    }
                    return null;
                  },
                  builder: (formFieldState) {
                    final errorText = formFieldState.errorText;
                    return SwitchListTile(
                      focusNode: termsFocusNode,
                      title: Text(
                        Strings.termsAndCond,
                        style: currentTheme.textTheme.subtitle2,
                      ),
                      subtitle: errorText != null
                          ? Text(
                              errorText,
                              style: currentTheme.textTheme.bodyText2
                                  ?.copyWith(color: currentTheme.errorColor),
                            )
                          : null,
                      contentPadding: const EdgeInsets.only(right: 8.0),
                      value: aceptedTerms,
                      onChanged: (value) =>
                          setState(() => aceptedTerms = value),
                    );
                  },
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      final formState = Form.of(context);
                      if (formState != null && formState.validate()) {
                        showSignUpDialog(context);
                      }
                    },
                    child: const Text(Strings.button),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? phoneValidator(String? phone) {
    if (validatorEmptyField(phone) == null && phone != null) {
      final insertedPhone = phoneMask.unmaskText(phone);
      if (insertedPhone.length < 11) {
        return Strings.invalidNumber;
      }
    }
    return Strings.emptyField;
  }

  String? passwordValidator(String? passowrd) {
    if (passowrd == null || passowrd.isEmpty) {
      return Strings.emptyField;
    }
    if (passowrd.length < 8) {
      return Strings.passwordHelper;
    }
    return null;
  }

  String? emailValidator(String? email) {
    if (validatorEmptyField(email) == null) {
      if (email != null && !emailRegex.hasMatch(email)) {
        return Strings.invalidEmail;
      }
    }
    if (validatorEmptyField(email) != null) {
      return Strings.emptyField;
    }
    return null;
  }

  String? validatorEmptyField(String? text) {
    if (text == null || text.isEmpty) {
      return Strings.emptyField;
    }
    return null;
  }

  @override
  void dispose() {
    birthDateController.dispose();
    birthDateFocusNode.dispose();
    termsFocusNode.dispose();
    userNameFocusNome.dispose();
    super.dispose();
  }

  Padding buildHeader(String header) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Text(
        header,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }

  InputDecoration buildInputDecoration(String labelText) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      labelText: labelText,
    );
  }

  void showSignUpDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(Strings.appName),
          content: const Text(Strings.confirMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sim'),
            ),
          ],
        );
      },
    ).then((wasConfirmed) {
      if (wasConfirmed == true) {
        emailChecked = true;
        phoneChecked = true;
        aceptedTerms = false;

        Form.of(context)?.reset();
        birthDateController.clear();
        userNameFocusNome.requestFocus();

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(Strings.userWasSignedUp)));
      }
    });
  }

  void showBirthDate() {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    showDatePicker(
      context: context,
      firstDate: DateTime(1890),
      initialDate: eighteenYearsAgo,
      lastDate: eighteenYearsAgo,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.year,
    ).then((selectedDate) {
      if (selectedDate != null) {
        birthDateController.text =
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
        phoneFocusNode.requestFocus();
      }
    });
    birthDateFocusNode.unfocus();
  }
}
