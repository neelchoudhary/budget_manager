// Styling: Prepend all string constants with "kStr"
import 'dart:ui';

const String kStr_login_pin_prompt = "Enter the PIN";

const Color kColor_login_background = Color(0xff4C61BE);
const Color kColor_main_panel_bank = Color(0xff4C61BE);
const Color kColor_main_background_top = Color(0xff3D4B93);

const Color kColor_pink = Color(0xffFE6B8D);

const prof_pic =
    "https://media.licdn.com/dms/image/C5603AQE1KSHMj0PSoQ/profile-displayphoto-shrink_200_200/0?e=1582761600&v=beta&t=H-GnMYs2Y7e_PSPKklxDDchpbi5s2jksb0fYLZwBEV4";

String toTitle(String str) {
  str = str.toLowerCase();
  str = str.replaceFirst("quickpay with zelle", "");
  String title = "";
  for (String s in str.split(" ")) {
    if (s.length > 1) {
      title += (s[0].toUpperCase() + s.substring(1));
    } else if (s.length == 1) {
      title += (s[0].toUpperCase());
    }
    title += " ";
  }
  return title.substring(0, title.length - 1);
}
