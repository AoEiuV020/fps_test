import 'package:flutter/material.dart';
import 'dart:async';

class FpsTestView extends StatefulWidget {
  const FpsTestView({super.key});

  static const routeName = '/fps_test';

  @override
  State<FpsTestView> createState() => _FpsTestViewState();
}

class _FpsTestViewState extends State<FpsTestView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int currentFrame = 0;
  static const int totalFrames = 60;

  double elapsedTime = 0.0;
  int frameCount = 0;
  int framesPerSecond = 0;
  Timer? _elapsedTimer;
  Timer? _fpsTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {
          frameCount++;
          currentFrame = frameCount % totalFrames;
        });
      });

    _controller.repeat();

    _elapsedTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        elapsedTime = timer.tick / 10;
      });
    });

    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        framesPerSecond = frameCount;
        frameCount = 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _elapsedTimer?.cancel();
    _fpsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 网格区域（全屏）
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 10;
              final itemHeight = constraints.maxHeight / 6;

              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  childAspectRatio: itemWidth / itemHeight,
                ),
                itemCount: totalFrames,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(1),
                    color: index == currentFrame ? Colors.white : Colors.black,
                  );
                },
              );
            },
          ),
          // 信息显示区域（居中）
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '当前帧: ${(currentFrame + 1).toString().padLeft(2, '0')}/60',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'monospace', // 使用等宽字体
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '已运行时间: ${elapsedTime.toStringAsFixed(1).padLeft(4, ' ')}秒',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '平均帧率: ${framesPerSecond.toString().padLeft(2, ' ')} FPS',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 添加悬浮的关闭按钮
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
