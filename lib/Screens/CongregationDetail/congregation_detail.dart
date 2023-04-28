import 'package:flutter/material.dart';
import 'package:lw_app/Models/Congregation/congregation.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Models/AdditionalService/additional_service.dart';

class CongregationDetail extends StatefulWidget {
  final Congregation congregation;
  const CongregationDetail({super.key, required this.congregation});

  @override
  State<CongregationDetail> createState() => _CongregationDetailState();
}

class _CongregationDetailState extends State<CongregationDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const CircleAvatar(
                  radius: 100,
                  backgroundImage: NetworkImage(
                      "https://yt3.googleusercontent.com/ytc/AL5GRJUbsh7ILjzuEQAZTot_kkV2GohZR75CjoWM9NSI9Q=s900-c-k-c0x00ffffff-no-rj"),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.congregation.name,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                ),
                Text(
                  widget.congregation?.streetAddress ?? '',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Sunday Service',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16.0),
                    ),
                    Text(
                      DateFormatter.formatTimeString(
                        time: widget.congregation?.serviceStart,
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: widget.congregation?.servicesOffered
                      ?.map(
                          (service) => _createServiceItem(serviceItem: service))
                      .toList() ?? [SizedBox()],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createServiceItem({required dynamic serviceItem}) {
    AdditionalService service = AdditionalService.fromJson(
      Map<String, dynamic>.from(serviceItem),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          service?.serviceName ?? '',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16.0),
        ),
        Text(
          service?.serviceDay ?? '',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w200,
          ),
        ),
        Text(
          DateFormatter.formatTimeString(
            time: service.serviceTime,
            format: 'HH:mm',
          ),
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w200,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
