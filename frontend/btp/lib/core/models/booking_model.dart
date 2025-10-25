// Modèles pour les devis et réservations
class Quote {
  final int id;
  final int projectId;
  final int clientId;
  final String title;
  final String? description;
  final double totalAmount;
  final String currency;
  final DateTime? validUntil;
  final bool isAccepted;
  final DateTime? acceptedAt;
  final List<QuoteService> services;
  final List<String> workerRequirements;
  final List<String> equipmentRequirements;
  final String? termsAndConditions;
  final String? paymentTerms;
  final int? warrantyPeriod;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Quote({
    required this.id,
    required this.projectId,
    required this.clientId,
    required this.title,
    this.description,
    required this.totalAmount,
    required this.currency,
    this.validUntil,
    required this.isAccepted,
    this.acceptedAt,
    required this.services,
    required this.workerRequirements,
    required this.equipmentRequirements,
    this.termsAndConditions,
    this.paymentTerms,
    this.warrantyPeriod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      clientId: json['client_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until'] as String) : null,
      isAccepted: json['is_accepted'] as bool? ?? false,
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at'] as String) : null,
      services: json['services'] != null 
          ? (json['services'] as List).map((s) => QuoteService.fromJson(s as Map<String, dynamic>)).toList()
          : [],
      workerRequirements: List<String>.from(json['worker_requirements'] as List? ?? []),
      equipmentRequirements: List<String>.from(json['equipment_requirements'] as List? ?? []),
      termsAndConditions: json['terms_and_conditions'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      warrantyPeriod: json['warranty_period'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'client_id': clientId,
      'title': title,
      'description': description,
      'total_amount': totalAmount,
      'currency': currency,
      'valid_until': validUntil?.toIso8601String(),
      'is_accepted': isAccepted,
      'accepted_at': acceptedAt?.toIso8601String(),
      'services': services.map((s) => s.toJson()).toList(),
      'worker_requirements': workerRequirements,
      'equipment_requirements': equipmentRequirements,
      'terms_and_conditions': termsAndConditions,
      'payment_terms': paymentTerms,
      'warranty_period': warrantyPeriod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get amountDisplay => '${totalAmount.toStringAsFixed(0)} $currency';
  bool get isExpired => validUntil != null && DateTime.now().isAfter(validUntil!);
}

class QuoteService {
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String unit;

  const QuoteService({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  factory QuoteService.fromJson(Map<String, dynamic> json) {
    return QuoteService(
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  double get totalPrice => price * quantity;
}

class Booking {
  final int id;
  final BookingType bookingType;
  final int clientId;
  final int? projectId;
  final int? quoteId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final double paidAmount;
  final double depositAmount;
  final String currency;
  final int? workerId;
  final String? description;
  final String? specialRequirements;
  final String? notes;
  final int? clientRating;
  final String? clientReview;
  final int? workerRating;
  final String? workerReview;
  final List<EquipmentBooking> equipmentBookings;
  final List<Payment> payments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.bookingType,
    required this.clientId,
    this.projectId,
    this.quoteId,
    required this.startDate,
    required this.endDate,
    this.actualStartDate,
    this.actualEndDate,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.depositAmount,
    required this.currency,
    this.workerId,
    this.description,
    this.specialRequirements,
    this.notes,
    this.clientRating,
    this.clientReview,
    this.workerRating,
    this.workerReview,
    required this.equipmentBookings,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      bookingType: BookingType.fromString(json['booking_type'] as String),
      clientId: json['client_id'] as int,
      projectId: json['project_id'] as int?,
      quoteId: json['quote_id'] as int?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      actualStartDate: json['actual_start_date'] != null ? DateTime.parse(json['actual_start_date'] as String) : null,
      actualEndDate: json['actual_end_date'] != null ? DateTime.parse(json['actual_end_date'] as String) : null,
      status: BookingStatus.fromString(json['status'] as String),
      paymentStatus: PaymentStatus.fromString(json['payment_status'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num? ?? 0.0).toDouble(),
      depositAmount: (json['deposit_amount'] as num? ?? 0.0).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      workerId: json['worker_id'] as int?,
      description: json['description'] as String?,
      specialRequirements: json['special_requirements'] as String?,
      notes: json['notes'] as String?,
      clientRating: json['client_rating'] as int?,
      clientReview: json['client_review'] as String?,
      workerRating: json['worker_rating'] as int?,
      workerReview: json['worker_review'] as String?,
      equipmentBookings: json['equipment_bookings'] != null 
          ? (json['equipment_bookings'] as List).map((eb) => EquipmentBooking.fromJson(eb as Map<String, dynamic>)).toList()
          : [],
      payments: json['payments'] != null 
          ? (json['payments'] as List).map((p) => Payment.fromJson(p as Map<String, dynamic>)).toList()
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_type': bookingType.value,
      'client_id': clientId,
      'project_id': projectId,
      'quote_id': quoteId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'actual_start_date': actualStartDate?.toIso8601String(),
      'actual_end_date': actualEndDate?.toIso8601String(),
      'status': status.value,
      'payment_status': paymentStatus.value,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'deposit_amount': depositAmount,
      'currency': currency,
      'worker_id': workerId,
      'description': description,
      'special_requirements': specialRequirements,
      'notes': notes,
      'client_rating': clientRating,
      'client_review': clientReview,
      'worker_rating': workerRating,
      'worker_review': workerReview,
      'equipment_bookings': equipmentBookings.map((eb) => eb.toJson()).toList(),
      'payments': payments.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get amountDisplay => '${totalAmount.toStringAsFixed(0)} $currency';
  String get durationDisplay {
    final duration = endDate.difference(startDate);
    if (duration.inDays > 0) return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''}';
    if (duration.inHours > 0) return '${duration.inHours} heure${duration.inHours > 1 ? 's' : ''}';
    return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
  }
  double get paymentProgress => totalAmount > 0 ? paidAmount / totalAmount : 0.0;
}

class EquipmentBooking {
  final int id;
  final int bookingId;
  final int equipmentId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;
  final double? dailyRate;
  final double totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EquipmentBooking({
    required this.id,
    required this.bookingId,
    required this.equipmentId,
    required this.startDate,
    required this.endDate,
    this.actualStartDate,
    this.actualEndDate,
    this.dailyRate,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EquipmentBooking.fromJson(Map<String, dynamic> json) {
    return EquipmentBooking(
      id: json['id'] as int,
      bookingId: json['booking_id'] as int,
      equipmentId: json['equipment_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      actualStartDate: json['actual_start_date'] != null ? DateTime.parse(json['actual_start_date'] as String) : null,
      actualEndDate: json['actual_end_date'] != null ? DateTime.parse(json['actual_end_date'] as String) : null,
      dailyRate: json['daily_rate'] != null ? (json['daily_rate'] as num).toDouble() : null,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: BookingStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'equipment_id': equipmentId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'actual_start_date': actualStartDate?.toIso8601String(),
      'actual_end_date': actualEndDate?.toIso8601String(),
      'daily_rate': dailyRate,
      'total_amount': totalAmount,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Payment {
  final int id;
  final int bookingId;
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String? paymentReference;
  final PaymentStatus status;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    this.paymentReference,
    required this.status,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      bookingId: json['booking_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      paymentMethod: json['payment_method'] as String?,
      paymentReference: json['payment_reference'] as String?,
      status: PaymentStatus.fromString(json['status'] as String),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'status': status.value,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get amountDisplay => '${amount.toStringAsFixed(0)} $currency';
}

enum BookingType {
  worker('worker', 'Ouvrier'),
  equipment('equipment', 'Équipement'),
  both('both', 'Ouvrier + Équipement');

  const BookingType(this.value, this.label);
  final String value;
  final String label;

  static BookingType fromString(String value) {
    return BookingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BookingType.worker,
    );
  }
}

enum BookingStatus {
  pending('pending', 'En attente'),
  confirmed('confirmed', 'Confirmé'),
  inProgress('in_progress', 'En cours'),
  completed('completed', 'Terminé'),
  cancelled('cancelled', 'Annulé'),
  rejected('rejected', 'Rejeté');

  const BookingStatus(this.value, this.label);
  final String value;
  final String label;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

enum PaymentStatus {
  pending('pending', 'En attente'),
  partial('partial', 'Partiel'),
  paid('paid', 'Payé'),
  refunded('refunded', 'Remboursé'),
  failed('failed', 'Échoué');

  const PaymentStatus(this.value, this.label);
  final String value;
  final String label;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}
