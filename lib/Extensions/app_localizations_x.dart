import 'package:lw_app/Models/AppFeedback/app_feedback.dart';
import 'package:lw_app/Models/Group/group_membership.dart';
import 'package:lw_app/Models/PrayerRequest/prayer_request.dart';
import 'package:lw_app/l10n/app_localizations.dart';

extension FeedbackCategoryL10n on FeedbackCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case FeedbackCategory.bugReport:
        return l10n.feedbackCategoryBugReport;
      case FeedbackCategory.featureRequest:
        return l10n.feedbackCategoryFeatureRequest;
      case FeedbackCategory.improvement:
        return l10n.feedbackCategoryImprovement;
      case FeedbackCategory.other:
        return l10n.feedbackCategoryOther;
    }
  }
}

extension FeedbackStatusL10n on FeedbackStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case FeedbackStatus.open:
        return l10n.feedbackStatusOpen;
      case FeedbackStatus.underReview:
        return l10n.feedbackStatusUnderReview;
      case FeedbackStatus.planned:
        return l10n.feedbackStatusPlanned;
      case FeedbackStatus.resolved:
        return l10n.feedbackStatusResolved;
      case FeedbackStatus.closed:
        return l10n.feedbackStatusClosed;
    }
  }
}

extension PrayerCategoryL10n on PrayerCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case PrayerCategory.healing:
        return l10n.prayerCategoryHealing;
      case PrayerCategory.family:
        return l10n.prayerCategoryFamily;
      case PrayerCategory.provision:
        return l10n.prayerCategoryProvision;
      case PrayerCategory.guidance:
        return l10n.prayerCategoryGuidance;
      case PrayerCategory.spiritualGrowth:
        return l10n.prayerCategorySpiritualGrowth;
      case PrayerCategory.thanksgiving:
        return l10n.prayerCategoryThanksgiving;
      case PrayerCategory.other:
        return l10n.prayerCategoryOther;
    }
  }
}

extension PrayerStatusL10n on PrayerRequestStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case PrayerRequestStatus.pending:
        return l10n.prayerStatusPending;
      case PrayerRequestStatus.approved:
        return l10n.prayerStatusApproved;
      case PrayerRequestStatus.rejected:
        return l10n.prayerStatusRejected;
      case PrayerRequestStatus.resolved:
        return l10n.prayerStatusResolved;
    }
  }
}

extension GroupMembershipStatusL10n on String {
  String groupMembershipLabel(AppLocalizations l10n) {
    switch (this) {
      case GroupMembershipStatus.pending:
        return l10n.groupMembershipStatusPending;
      case GroupMembershipStatus.active:
        return l10n.groupMembershipStatusActive;
      case GroupMembershipStatus.declined:
        return l10n.groupMembershipStatusDeclined;
      case GroupMembershipStatus.left:
        return l10n.groupMembershipStatusLeft;
      case GroupMembershipStatus.removed:
        return l10n.groupMembershipStatusRemoved;
      default:
        return this;
    }
  }
}
