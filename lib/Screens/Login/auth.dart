/*
 *  This file is part of wrld999 (https://github.com/shad0wrider/wrld999).
 *
 * wrld999 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wrld999 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with wrld999.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:wrld999/CustomWidgets/gradient_containers.dart';
import 'package:wrld999/Helpers/backup_restore.dart';
import 'package:wrld999/Helpers/config.dart';
import 'package:wrld999/Services/firebase_auth_service.dart';
import 'package:wrld999/localization/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController controller = TextEditingController();
  Uuid uuid = const Uuid();
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future _addUserData(String name) async {
    await Hive.box('settings').put('name', name.trim());
    final String userId = uuid.v1();
    await Hive.box('settings').put('userId', userId);
    await Hive.box('settings').put('isGoogleSignIn', false);
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await FirebaseAuthService.signInWithGoogle();
      if (user == null) {
        // user cancelled the picker
        setState(() => _isGoogleLoading = false);
        return;
      }
      if (!mounted) return;
      Navigator.popAndPushNamed(context, '/pref');
    } catch (e) {
      setState(() {
        _isGoogleLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: MediaQuery.of(context).size.width / 1.85,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  child: const Image(
                    image: AssetImage(
                      'assets/icon-white-trans.png',
                    ),
                  ),
                ),
              ),
              const GradientContainer(
                child: null,
                opacity: true,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await restore(context);
                          GetIt.I<MyTheme>().refresh();
                          Navigator.popAndPushNamed(context, '/');
                        },
                        child: Text(
                          AppLocalizations.of(context)!.restore,
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha:0.7),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _addUserData(
                            AppLocalizations.of(context)!.guest,
                          );
                          Navigator.popAndPushNamed(context, '/pref');
                        },
                        child: Text(
                          AppLocalizations.of(context)!.skip,
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha:0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Black\nHole\n',
                                    style: TextStyle(
                                      height: 0.97,
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    children: <TextSpan>[
                                      const TextSpan(
                                        text: 'Music',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 80,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            Column(
                              children: [
                                // Google Sign-In button
                                GestureDetector(
                                  onTap: _isGoogleLoading
                                      ? null
                                      : _signInWithGoogle,
                                  child: Container(
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          offset: Offset(0.0, 3.0),
                                        ),
                                      ],
                                    ),
                                    child: _isGoogleLoading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/google_logo.png',
                                                height: 24,
                                                width: 24,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                  Icons.login,
                                                  color: Colors.black87,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Sign in with Google',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.withValues(alpha:0.4),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                      ),
                                      child: Text(
                                        'or',
                                        style: TextStyle(
                                          color: Colors.grey.withValues(alpha:0.7),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.withValues(alpha:0.4),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Name entry (guest flow)
                                Container(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: 10,
                                    right: 10,
                                  ),
                                  height: 57.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.grey[900],
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                        offset: Offset(0.0, 3.0),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: controller,
                                    textAlignVertical: TextAlignVertical.center,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 1.5,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                      border: InputBorder.none,
                                      hintText: AppLocalizations.of(context)!
                                          .enterName,
                                      hintStyle: const TextStyle(
                                        color: Colors.white60,
                                      ),
                                    ),
                                    onSubmitted: (String value) async {
                                      if (value.trim() == '') {
                                        await _addUserData(
                                          AppLocalizations.of(context)!.guest,
                                        );
                                      } else {
                                        await _addUserData(value.trim());
                                      }
                                      Navigator.popAndPushNamed(
                                        context,
                                        '/pref',
                                      );
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (controller.text.trim() == '') {
                                      await _addUserData('Guest');
                                    } else {
                                      await _addUserData(
                                        controller.text.trim(),
                                      );
                                    }
                                    Navigator.popAndPushNamed(context, '/pref');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          offset: Offset(0.0, 3.0),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .getStarted,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(
                                    '${AppLocalizations.of(context)!.disclaimer} ${AppLocalizations.of(context)!.disclaimerText}',
                                    style: TextStyle(
                                      color: Colors.grey.withValues(alpha:0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
