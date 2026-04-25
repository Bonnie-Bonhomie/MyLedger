import 'dart:async';

import 'package:flutter/material.dart';
import 'package:facial_liveness_verification/facial_liveness_verification.dart';
import 'package:camera/camera.dart';

class LivenessScreen extends StatefulWidget {
  const LivenessScreen({super.key});

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> with WidgetsBindingObserver{
  late LivenessDetector _detector;

  String _instruction = "Initializing...";
  late StreamSubscription _subscription;
  bool _isCompleted = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLiveness();
  }

  Future<void> _initLiveness() async {
    _detector = LivenessDetector(
      const LivenessConfig(
        challenges: [
          ChallengeType.blink,
          ChallengeType.smile,
          ChallengeType.turnLeft,
          ChallengeType.turnRight,
        ],
        enableAntiSpoofing: true,
      ),
    );

    await _detector.initialize();

   _subscription = _detector.stateStream.listen((state) {
      if (!mounted) return;

      switch (state.type) {
        case LivenessStateType.faceDetected:
          setState(() => _instruction = "Face detected");
          break;

        case LivenessStateType.positioned:
          setState(() => _instruction = "Hold still...");
          break;

        case LivenessStateType.challengeInProgress:
          setState(() =>
          _instruction = state.currentChallenge?.instruction ?? "Follow instruction");
          break;

        case LivenessStateType.completed:
          setState(() {
            _instruction = "Verification Successful";
            _isCompleted = true;
          });
          break;

        case LivenessStateType.error:
          setState(() {
            _instruction = state.error?.message ?? "Error occurred";
            _hasError = true;
          });
          break;

        default:
          break;
      }
    });

    // await _detector.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = _detector.cameraController;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Liveness Verification"),
        backgroundColor: Colors.black,
      ),
      body:
      camera == null || !camera.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Camera Preview
          CameraPreview(camera),

         // Face Overlay
          Center(
            child: Container(
              width: 260,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isCompleted
                      ? Colors.green
                      : _hasError
                      ? Colors.red
                      : Colors.white,
                  width: 3,
                ),
                // borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Instruction Text
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  _instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Retry Button
                if (_hasError)
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _hasError = false;
                        _isCompleted = false;
                        _instruction = "Restarting...";
                      });

                      await _detector.stop();
                      await _detector.start();
                    },
                    child: const Text("Retry"),
                  ),

                // Continue Button
                if (_isCompleted)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text("Continue"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}