import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class TithesOfferingsScreen extends StatelessWidget {
  const TithesOfferingsScreen({super.key});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    LwpSnackbar.showSuccess(
      context,
      '$label gekopieer na knipbord',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiendes & Offergawes'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  // TODO: Replace with Cloudinary header image URL
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?auto=format&fit=crop&q=80&w=1000',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                alignment: Alignment.bottomLeft,
                child: const Text(
                  'Gee met \'n Blye Hart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Elkeen moet gee soos hy hom in sy hart voorgeneem het, nie met teensin of uit dwang nie, want God het \'n blymoedige gewer lief.\n— 2 Korintiërs 9:7',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),

            // EFT Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance, color: theme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Bankbesonderhede (EFT)',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildDetailRow(
                        context,
                        'Bank',
                        'ABSA Bank', // Placeholder bank
                        isCopyable: false,
                      ),
                      _buildDetailRow(
                        context,
                        'Rekeningnaam',
                        'Lewende Woord Paarl',
                        isCopyable: false,
                      ),
                      _buildDetailRow(
                        context,
                        'Rekeningnommer',
                        '123456789', // Placeholder account number
                        isCopyable: true,
                        copyLabel: 'Rekeningnommer',
                      ),
                      _buildDetailRow(
                        context,
                        'Takkode',
                        '632005', // Placeholder branch code
                        isCopyable: true,
                        copyLabel: 'Takkode',
                      ),
                      _buildDetailRow(
                        context,
                        'Verwysing',
                        'Tiendes / Jou Naam',
                        isCopyable: true,
                        copyLabel: 'Verwysing',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SnapScan Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code_scanner, color: theme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Skandeer met SnapScan',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Container(
                        width: 200,
                        height: 200,
                        padding: const EdgeInsetsGeometry.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          child: const Image(
                            // TODO: Replace with SnapScan QR code Cloudinary URL
                            image: NetworkImage(
                              'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=SnapScanPlaceholder',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Maak jou SnapScan of Zapper toep oop en skandeer hierdie kode om vinnig en veilig te gee.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    required bool isCopyable,
    String? copyLabel,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            height: 32,
            child: isCopyable
                ? IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => _copyToClipboard(context, value, copyLabel ?? label),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    color: theme.primaryColor,
                    tooltip: 'Kopieer $label',
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
