import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/dialogs/app_toast.dart';

class StripeWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String orderId;

  const StripeWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
  });

  @override
  State<StripeWebViewScreen> createState() => _StripeWebViewScreenState();
}

class _StripeWebViewScreenState extends State<StripeWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _checkRedirect(url);
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            if (_checkRedirect(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _checkRedirect(String url) {
    // Intercept success redirect URL
    if (url.contains('/success') || url.contains('stripe/success')) {
      if (mounted) {
        context.go(AppRoutes.orderSuccessPath(widget.orderId));
      }
      return true;
    }

    // Intercept cancel redirect URL
    if (url.contains('/cancel') || url.contains('stripe/cancel')) {
      if (mounted) {
        AppToast.warning('Thanh toán đã bị hủy.', context: context);
        context.pop();
      }
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh Toán Stripe'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hủy thanh toán?'),
                content: const Text('Bạn có chắc muốn thoát phiên thanh toán trực tuyến này?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tiếp tục thanh toán'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      AppToast.warning(
                        'Đã hủy giao dịch Stripe. Đơn hàng vẫn lưu ở trạng thái chờ thanh toán.',
                        context: context,
                      );
                    },
                    child: const Text('Thoát', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
