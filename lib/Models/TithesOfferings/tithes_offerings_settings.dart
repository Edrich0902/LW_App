import 'package:equatable/equatable.dart';

class TithesOfferingsSettings extends Equatable {
  final String id;
  final String bank;
  final String accountName;
  final String accountNumber;
  final String branchCode;
  final String reference;
  final String? snapscanQrUrl;
  final String? headerImagePublicId;
  final String? headerImageUrl;

  const TithesOfferingsSettings({
    required this.id,
    required this.bank,
    required this.accountName,
    required this.accountNumber,
    required this.branchCode,
    required this.reference,
    this.snapscanQrUrl,
    this.headerImagePublicId,
    this.headerImageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        bank,
        accountName,
        accountNumber,
        branchCode,
        reference,
        snapscanQrUrl,
        headerImagePublicId,
        headerImageUrl,
      ];

  factory TithesOfferingsSettings.fromJson(Map<String, dynamic> json) {
    return TithesOfferingsSettings(
      id: json['id'] ?? '',
      bank: json['bank'] ?? '',
      accountName: json['account_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      branchCode: json['branch_code'] ?? '',
      reference: json['reference'] ?? '',
      snapscanQrUrl: json['snapscan_qr_url'],
      headerImagePublicId: json['header_image_public_id'],
      headerImageUrl: json['header_image_url'],
    );
  }
}
