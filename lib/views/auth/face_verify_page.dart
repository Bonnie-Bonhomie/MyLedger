import 'dart:async';

import 'package:flutter/material.dart';
import 'package:facial_liveness_verification/facial_liveness_verification.dart';
import 'package:camera/camera.dart';

class LivenessScreen extends StatefulWidget {
  const LivenessScreen({super.key});

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen>
    with WidgetsBindingObserver {
  late LivenessDetector _detector;
  late CameraController _camera;

  String _instruction = "Initializing...";
  late StreamSubscription _subscription;
  bool _isCompleted = false;
  bool _hasError = false;
  bool _isInitialized = false;
  bool _isPositionLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLiveness();
  }

  LivenessStateType? _lastState;
  Timer? _debounce;

  String _mapInstruction(LivenessState state) {
    switch (state.type) {
      case LivenessStateType.noFace:
        return "Stay in a light environment";
      case LivenessStateType.faceDetected:
        return "Align your face inside the frame";

      case LivenessStateType.positioned:
        return "Hold still...";

      case LivenessStateType.challengeInProgress:
        return state.currentChallenge?.instruction ?? "Follow the instruction";

      case LivenessStateType.completed:
        return "Verification successful";

      case LivenessStateType.error:
        return state.error?.message ?? "Something went wrong";

      default:
        return "Initializing...";
    }
  }

  Future<void> _initLiveness() async {
    _detector = LivenessDetector(
      const LivenessConfig(
        challenges: [
          ChallengeType.blink,
          ChallengeType.smile,
          // ChallengeType.turnLeft,
          // ChallengeType.turnRight,
        ],
        enableAntiSpoofing: true,
      ),
    );

    await _detector.initialize();

    _camera = _detector.cameraController!;

    //  Wait until camera is initialized
    while (!_camera.value.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await Future.delayed(const Duration(seconds: 1));

    _subscription = _detector.stateStream.listen((state) {
      print("STATE: ${state.type}");
      print("ERROR: ${state.error?.message}");
      //Handle state changes
     stateHandler(state);
    });
    await _detector.start();

    setState(() {
      _isInitialized = true;
    });
  }

  void stateHandler(LivenessState state) {

      // if (!mounted) return;
      if (state.type == _lastState) return;
      _lastState = state.type;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        if (state.type == LivenessStateType.positioned) {
          Future.delayed(const Duration(seconds: 1), () {
            _isPositionLocked = true;
          });
        }

        if (!_isPositionLocked &&
            state.type == LivenessStateType.challengeInProgress) {
          return;
        }

        setState(() {
          _instruction = _mapInstruction(state);

          if (state.type == LivenessStateType.completed) {
            _isCompleted = true;
          }

          if (state.type == LivenessStateType.error) {
            _hasError = true;
          }
          //End
        });
      });
    // });
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Liveness Verification"),
        backgroundColor: Colors.black,
      ),
      body:
          !_isInitialized
          // _camera == null || !_camera.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Camera Preview
                CameraPreview(_camera),

                // Face Overlay
                Center(
                  child: Container(
                    width: 260,
                    height: 350,
                    decoration: BoxDecoration(
                      // shape: BoxShape.circle,
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
