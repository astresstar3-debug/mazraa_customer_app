import 'package:flutter/material.dart';

import 'matched_auth_location_screens.dart';

/// Keeps the reference OTP composition intact while allowing it to render on
/// the Pixel 6 viewport used by screenshot CI without a RenderFlex overflow.
/// The production OTP route does not use this wrapper.
class ReferencePhoneVerificationScreen extends StatelessWidget {
  const ReferencePhoneVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          // The matched reference composition is only a few logical pixels
          // taller than the CI viewport. Give it a small extra layout canvas
          // and scale it down uniformly instead of changing individual visual
          // measurements from the reference design.
          final logicalHeight = constraints.maxHeight + 20;
          return ClipRect(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.maxWidth,
                height: logicalHeight,
                child: const MatchedPhoneVerificationScreen(),
              ),
            ),
          );
        },
      );
}
