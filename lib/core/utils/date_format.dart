class DateFormat {

  DateFormat._();

  static String formatDate(DateTime date) {
    List<String> months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    String day = date.day.toString().padLeft(2, '0');
    String month = months[date.month - 1];
    String year = date.year.toString();

    return "$day $month $year";
  }

}