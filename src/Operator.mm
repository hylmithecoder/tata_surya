#include "../include/Operator.hpp"

using namespace Tugas;

void label(string text, Utils::BaseWindow *myWindow) {
  myWindow->addLabel(text, 12, "white");
}

void Operator::soal1() {
  Utils::BaseWindow *myWindow = new Utils::BaseWindow(500, 500, "Soal 1");

  myWindow->setLabelAlignment("center");
  myWindow->addLabel(
      "Hitunglah hasil bilangan berikut dengan operator and, or, dan xor!", 12,
      "blue");
  myWindow->addSeparator();

  myWindow->setLabelAlignment("right");
  label("1. A = 45, B = 70", myWindow);
  label("2. A = 12, B = 49", myWindow);
  label("3. A = 66, B = 23", myWindow);
  label("4. A = 88, B = 72", myWindow);
  label("5. A = 19, B = 90", myWindow);
  label("6. A = 59, B = 31", myWindow);

  int sub1[] = {45 & 70, 45 | 70, 45 ^ 70};
  int sub2[] = {12 & 49, 12 | 49, 12 ^ 49};
  int sub3[] = {66 & 23, 66 | 23, 66 ^ 23};
  int sub4[] = {88 & 72, 88 | 72, 88 ^ 72};
  int sub5[] = {19 & 90, 19 | 90, 19 ^ 90};
  int sub6[] = {59 & 31, 59 | 31, 59 ^ 31};

  myWindow->addSeparator();
  myWindow->addLabel("Jawaban:", 12, "yellow");
  myWindow->addSpacer(4);

  myWindow->setLabelAlignment("right");
  myWindow->addLabel(
      Utils::format("1. AND: %d | OR: %d | XOR: %d", sub1[0], sub1[1], sub1[2]),
      12);
  myWindow->addLabel(
      Utils::format("2. AND: %d | OR: %d | XOR: %d", sub2[0], sub2[1], sub2[2]),
      12);
  myWindow->addLabel(
      Utils::format("3. AND: %d | OR: %d | XOR: %d", sub3[0], sub3[1], sub3[2]),
      12);
  myWindow->addLabel(
      Utils::format("4. AND: %d | OR: %d | XOR: %d", sub4[0], sub4[1], sub4[2]),
      12);
  myWindow->addLabel(
      Utils::format("5. AND: %d | OR: %d | XOR: %d", sub5[0], sub5[1], sub5[2]),
      12);
  myWindow->addLabel(
      Utils::format("6. AND: %d | OR: %d | XOR: %d", sub6[0], sub6[1], sub6[2]),
      12);

  myWindow->show();
}

void Operator::soal2() {
  Utils::BaseWindow *myWindow = new Utils::BaseWindow(500, 400, "Soal 2");

  myWindow->setLabelAlignment("center");
  myWindow->addLabel("Cari Hasil dari!", 12, "blue");
  myWindow->addSeparator();

  myWindow->setLabelAlignment("right");
  myWindow->addLabel("1. C = A & B", 12);
  myWindow->addLabel("2. C = A | B", 12);
  myWindow->addLabel("3. C = A ^ B", 12);

  myWindow->addSpacer(6);
  myWindow->addInputRow("A:", "a", "Masukkan nilai A");
  myWindow->addInputRow("B:", "b", "Masukkan nilai B");
  myWindow->addSpacer(4);

  myWindow->addButton("Hitung", 0, 28, [myWindow]() {
    int a = std::stoi(myWindow->getInputValue("a"));
    int b = std::stoi(myWindow->getInputValue("b"));
    int c[] = {a & b, a | b, a ^ b};
    myWindow->addSeparator();
    myWindow->addLabel(
        Utils::format("C = A & B = %d\nC = A | B = %d\nC = A ^ B = %d", c[0],
                      c[1], c[2]),
        12, "green");
  });

  myWindow->show();
}

void Operator::soal3() {
  Utils::BaseWindow *myWindow = new Utils::BaseWindow(500, 400, "Soal 3");

  myWindow->setLabelAlignment("center");
  myWindow->addLabel("Hitunglah hasil right shift dan right shift untuk kedua "
                     "bilangan berikut!",
                     12, "blue");
  myWindow->addSeparator();

  int a = 30, b = 67, c = 78, d = 92;
  myWindow->setLabelAlignment("right");
  myWindow->addLabel(Utils::format("1. A = %d  =>  %d << 2 = %d", a, a, a << 2),
                     12);
  myWindow->addLabel(Utils::format("2. B = %d  =>  %d >> 2 = %d", b, b, b >> 2),
                     12);
  myWindow->addLabel(Utils::format("3. C = %d  =>  %d << 3 = %d", c, c, c << 3),
                     12);
  myWindow->addLabel(Utils::format("4. D = %d  =>  %d >> 1 = %d", d, d, d >> 1),
                     12);

  myWindow->show();
}

void Operator::soal4() {
  Utils::BaseWindow *myWindow = new Utils::BaseWindow(500, 550, "Soal 4");

  myWindow->setLabelAlignment("center");
  myWindow->addLabel("Buat sebuah program untuk menjalankan perintah bitwise "
                     "(and, or, dan xor) dalam sebuah program",
                     12, "blue");

  // ---- OR ----
  myWindow->addSeparator();
  myWindow->setLabelAlignment("center");
  myWindow->addLabel("Contoh OR", 12, "yellow");
  myWindow->addInputRow("A:", "a", "Masukkan nilai A");
  myWindow->addInputRow("B:", "b", "Masukkan nilai B");
  myWindow->addButton("Hitung OR", 0, 28, [myWindow]() {
    int a = std::stoi(myWindow->getInputValue("a"));
    int b = std::stoi(myWindow->getInputValue("b"));
    myWindow->addLabel(Utils::format("Hasil: C = A | B = %d", a | b), 12,
                       "green");
  });

  // ---- AND ----
  myWindow->addSeparator();
  myWindow->setLabelAlignment("center");
  myWindow->addLabel("Contoh AND", 12, "yellow");
  myWindow->addInputRow("A:", "a2", "Masukkan nilai A");
  myWindow->addInputRow("B:", "b2", "Masukkan nilai B");
  myWindow->addButton("Hitung AND", 0, 28, [myWindow]() {
    int a = std::stoi(myWindow->getInputValue("a2"));
    int b = std::stoi(myWindow->getInputValue("b2"));
    myWindow->addLabel(Utils::format("Hasil: C = A & B = %d", a & b), 12,
                       "green");
  });

  // ---- XOR ----
  myWindow->addSeparator();
  myWindow->setLabelAlignment("center");
  myWindow->addLabel("Contoh XOR", 12, "yellow");
  myWindow->addInputRow("A:", "a3", "Masukkan nilai A");
  myWindow->addInputRow("B:", "b3", "Masukkan nilai B");
  myWindow->addButton("Hitung XOR", 0, 28, [myWindow]() {
    int a = std::stoi(myWindow->getInputValue("a3"));
    int b = std::stoi(myWindow->getInputValue("b3"));
    myWindow->addLabel(Utils::format("Hasil: C = A ^ B = %d", a ^ b), 12,
                       "green");
  });

  myWindow->show();
}

void Operator::soal5() {
  Utils::BaseWindow *myWindow = new Utils::BaseWindow(500, 450, "Soal 5");

  myWindow->setLabelAlignment("center");
  myWindow->addLabel("Buat sebuah program untuk menjalankan perintah bitwise "
                     "(right shift, right shift) dalam sebuah program",
                     12, "blue");

  // ---- right Shift ----
  myWindow->addSeparator();
  myWindow->setLabelAlignment("center");
  myWindow->addLabel("Contoh right Shift", 12, "yellow");
  myWindow->addInputRow("A:", "a2", "Masukkan nilai A");
  myWindow->addInputRow("B:", "b2", "Masukkan jumlah shift");
  myWindow->addButton("Hitung <<", 0, 28, [myWindow]() {
    int a = std::stoi(myWindow->getInputValue("a2"));
    int b = std::stoi(myWindow->getInputValue("b2"));
    myWindow->addLabel(Utils::format("Hasil: C = A << B = %d", a << b), 12,
                       "green");
  });

  // ---- Right Shift ----
  myWindow->addSeparator();
  myWindow->setLabelAlignment("center");
  myWindow->addLabel("Contoh Right Shift", 12, "yellow");
  myWindow->addInputRow("A:", "a3", "Masukkan nilai A");
  myWindow->addInputRow("B:", "b3", "Masukkan jumlah shift");
  myWindow->addButton("Hitung >>", 0, 28, [myWindow]() {
    int a = std::stoi(myWindow->getInputValue("a3"));
    int b = std::stoi(myWindow->getInputValue("b3"));
    myWindow->addLabel(Utils::format("Hasil: C = A >> B = %d", a >> b), 12,
                       "green");
  });

  myWindow->show();
}