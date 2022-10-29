string lowercase(string _text) {
  for (int i = 0; i < _text.Length; i++) {    // for each character
    if (_text[i] >= "A"[0] && _text[i] <= "Z"[0]) // if the character is an uppercase letter
      _text[i] += 32;                            // convert it to its lowercase equivalent
  }
  return _text;
}