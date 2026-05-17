import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

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
        actions: const <Widget>[
          LwpAnnouncementButton(),
          ProfileActionButton()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image Placeholder (Split Screen Pattern)
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  // TODO: Replace with Cloudinary header image URL using CldImageWidget in future
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
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Gee met \'n Blye Hart',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text(
                'Elkeen moet gee soos hy hom in sy hart voorgeneem het, nie met teensin of uit dwang nie, want God het \'n blymoedige gewer lief.\n— 2 Korintiërs 9:7',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 8),

            // EFT Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.account_balance, color: theme.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bankbesonderhede (EFT)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.qr_code_scanner, color: theme.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Skandeer met SnapScan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Container(
                        width: 200,
                        height: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: const Image(
                            // TODO: Replace with SnapScan QR code Cloudinary URL
                            image: NetworkImage(
                              'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=SnapScanPlaceholder',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Maak jou SnapScan of Zapper toep oop en skandeer hierdie kode om vinnig en veilig te gee.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
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
