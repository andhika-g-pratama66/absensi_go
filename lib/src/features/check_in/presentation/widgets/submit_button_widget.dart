import 'package:absensi_go/src/features/check_in/provider/check_in_provider.dart';
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final bool isRequestIzin;
  final bool canSubmit;
  final CheckInState state;
  final DateTime? izinDate;
  final String alasanIzin;
  final VoidCallback? onSubmit;

  const SubmitButton({
    required this.isRequestIzin,
    required this.canSubmit,
    required this.state,
    required this.izinDate,
    required this.alasanIzin,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: canSubmit ? onSubmit : null,
            style: TextButton.styleFrom(
              backgroundColor: canSubmit
                  ? const Color(0xFF1A1A2E)
                  : Colors.grey.shade200,
              foregroundColor: canSubmit ? Colors.white : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              disabledBackgroundColor: Colors.grey.shade200,
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isRequestIzin ? 'Ajukan Izin' : 'Check In Sekarang',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
        if (state.errorMessage != null && !state.isSubmitting)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: Color(0xFF993C1D), fontSize: 13),
            ),
          ),
      ],
    );
  }
}
