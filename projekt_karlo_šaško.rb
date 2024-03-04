class VeterinarskaAmbulanta
  def initialize(ime, datum_rodenja, spol)
    @ime = ime
    @datum_rodenja = datum_rodenja
    @spol = spol
  end

  def get_ime
     @ime
  end

  def get_datum_rodenja
     @datum_rodenja
  end

  def get_spol
     @spol
  end


  def set_ime(novo_ime)
     @ime = novo_ime
  end

  def set_datum_rodenja(novi_datum_rodenja)
     @datum_rodenja = novi_datum_rodenja
  end

  def set_spol(novi_spol)
     @spol = novi_spol
  end

  def opis
    ""
  end

  def to_hash
    {
      'json_class' => self.class.name,
      'ime' => @ime,
      'datum_rodenja' => @datum_rodenja,
      'spol' => @spol
     }
  end
end

class Veterinar < VeterinarskaAmbulanta

  def initialize(ime,datum_rodenja,spol,broj_licence,prezime,adresa,broj_telefona,email)
      super ime, datum_rodenja, spol
      @broj_licence = broj_licence
      @prezime = prezime
      @adresa = adresa
      @broj_telefona = broj_telefona
      @email = email
  end

  def get_broj_licence
      @broj_licence
  end

  def get_prezime
      @prezime
  end

  def get_adresa
      @adresa
  end

  def get_broj_telefona
      @broj_telefona
  end

  def get_email
      @email
  end

  def set_broj_licence(novi_broj_licence)
      @broj_licence = novi_broj_licence
  end

  def set_prezime(novo_prezime)
      @prezime= novo_prezime
  end

  def set_adresa(nova_adresa)
      @adresa = nova_adresa
  end

  def set_broj_telefona(novi_broj_telefona)
      @broj_telefona = novi_broj_telefona
  end

  def set_email(novi_email)
      @email = novi_email
  end

  def opis
    super + "Veterinar"
  end

  def to_hash
    super.merge(
      'broj_licence' => @broj_licence,
      'prezime' => @prezime,
      'adresa' => @adresa,
      'broj_telefona' => @broj_telefona,
      'email' => @email
      )
  end
end


class Zivotinja < VeterinarskaAmbulanta

  def initialize(ime,datum_rodenja,spol,sifra, vrsta, pasmina)
     super ime, datum_rodenja, spol
     @sifra = sifra
     @vrsta = vrsta
     @pasmina = pasmina
  end


  def get_sifra
    @sifra
  end

  def get_vrsta
    @vrsta
  end

  def get_pasmina
    @pasmina
  end

  def set_sifra(nova_sifra)
    @sifra = nova_sifra
  end

  def set_vrsta(nova_vrsta)
    @vrsta = nova_vrsta
  end

  def set_pasmina(nova_pasmina)
    @pasmina = nova_pasmina
  end

  def opis
    super + "Zivotinja"
  end

  def to_hash
    super.merge(
      'sifra' => @sifra,
      'vrsta' => @vrsta,
      'pasmina' => @pasmina
    )
  end
end

module VeterinarskaAmbulantaManager
 require 'json'

def ucitaj_podatke
  file_path = File.join(File.dirname(__FILE__), 'veterinarske_ambulante.json')
  if File.exist?(file_path)
    podaci = File.read(file_path)
    veterinarske_ambulante = JSON.parse(podaci).map do |podatak|
      class_name = podatak['json_class']
      case class_name
        when 'Veterinar'
          Veterinar.new(podatak['ime'], podatak['datum_rodenja'], podatak['spol'], podatak['broj_licence'],podatak['prezime'],podatak['adresa'],podatak['broj_telefona'],podatak['email'])
        when 'Zivotinja'
          Zivotinja.new(podatak['ime'], podatak['datum_rodenja'], podatak['spol'], podatak['sifra'], podatak['vrsta'],podatak['pasmina'])
      end
    end
  else
    veterinarske_ambulante = []
  end
  veterinarske_ambulante
end



def spremi_podatke(veterinarske_ambulante)
  file_path = File.join(File.dirname(__FILE__), 'veterinarske_ambulante.json')
  serialized_data = JSON.generate(veterinarske_ambulante.map(&:to_hash))
  File.write(file_path, serialized_data)
end

def dodaj_veterinara(veterinarske_ambulante, ime_veterinara, datum_rodenja_veterinara, spol_veterinara, broj_licence_veterinara, prezime_veterinara, adresa_veterinara, broj_telefona_veterinara, email_veterinara)
  veterinarske_ambulante << Veterinar.new(ime_veterinara, datum_rodenja_veterinara, spol_veterinara, broj_licence_veterinara, prezime_veterinara, adresa_veterinara, broj_telefona_veterinara, email_veterinara)

end

def dodaj_zivotinju(veterinarske_ambulante,  ime_zivotinje, datum_rodenja_zivotinje, spol_zivotinje, sifra_zivotinje, vrsta_zivotinje, pasmina_zivotinje)
  veterinarske_ambulante << Zivotinja.new(ime_zivotinje, datum_rodenja_zivotinje, spol_zivotinje,sifra_zivotinje, vrsta_zivotinje, pasmina_zivotinje)
end

def brisi(ime,veterinarske_ambulante)
  veterinarske_ambulante.each { |bice| veterinarske_ambulante.delete(bice) if bice.get_ime().downcase == ime.downcase}
end

end


require 'fox16'
include Fox

class VeterinarskaAmbulantaApp < FXMainWindow
include VeterinarskaAmbulantaManager

def initialize(app)
super(app,"Veterinarska ambulanta", width: 500, height: 400)

veterinarske_ambulante = self.ucitaj_podatke()

combo = FXComboBox.new(self, 5, opts: COMBOBOX_STATIC | FRAME_SUNKEN | FRAME_THICK | LAYOUT_SIDE_TOP | LAYOUT_FILL_X)
combo.appendItem("Unos veterinara")
combo.appendItem("Unos zivotinje")
combo.appendItem("Prikaz i azuriranje")
combo.appendItem("Brisanje ")
combo.appendItem("Izlaz")
combo.numVisible = 5


# Frame za unos veterinara
@unos_veterinara_frame = FXHorizontalFrame.new(self, opts: LAYOUT_FILL_X|LAYOUT_FILL_Y)
@labela_frame_veterinara = FXVerticalFrame.new(@unos_veterinara_frame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_SIDE_LEFT)
FXLabel.new(@labela_frame_veterinara, "Ime:")
FXLabel.new(@labela_frame_veterinara, "Prezime")
FXLabel.new(@labela_frame_veterinara, "Datum rodenja:")
FXLabel.new(@labela_frame_veterinara, "Spol")
FXLabel.new(@labela_frame_veterinara, "Broj licence: ")
FXLabel.new(@labela_frame_veterinara, "Adresa")
FXLabel.new(@labela_frame_veterinara, "Broj telefona")
FXLabel.new(@labela_frame_veterinara, "Email")

@podaci_frame_veterinara = FXVerticalFrame.new(@unos_veterinara_frame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_SIDE_RIGHT)
@ime_veterinara = FXTextField.new(@podaci_frame_veterinara, 20, opts: LAYOUT_FILL_X)
@datum_rodenja_veterinara = FXTextField.new(@podaci_frame_veterinara, 20, opts: LAYOUT_FILL_X)
@spol_veterinara = FXTextField.new(@podaci_frame_veterinara, 20, opts: LAYOUT_FILL_X)
@prezime_veterinara = FXTextField.new(@podaci_frame_veterinara, 20, opts: LAYOUT_FILL_X)
@broj_licence_veterinara = FXTextField.new(@podaci_frame_veterinara, 20, opts: LAYOUT_FILL_X)
@adresa_veterinara = FXTextField.new(@podaci_frame_veterinara, 20, opts: LAYOUT_FILL_X)
@broj_telefona_veterinara = FXTextField.new(@podaci_frame_veterinara, 20, opts: LAYOUT_FILL_X)
@email_veterinara = FXTextField.new(@podaci_frame_veterinara, 20, opts: LAYOUT_FILL_X)

@tipka_dodaj_veterinara = FXButton.new(@podaci_frame_veterinara, "Dodaj veterinara")

@tipka_dodaj_veterinara.connect(SEL_COMMAND) do
  self.dodaj_veterinara(veterinarske_ambulante, @ime_veterinara.text, @prezime_veterinara.text,@datum_rodenja_veterinara.text, @spol_veterinara.text,@broj_licence_veterinara.text,@adresa_veterinara.text,@broj_telefona_veterinara.text,@email_veterinara.text)
  @ime_veterinara.text = ""
  @prezime_veterinara.text = ""
  @broj_licence_veterinara.text = ""
  @datum_rodenja_veterinara.text=""
  @spol_veterinara.text=""
  @adresa_veterinara.text=""
  @broj_telefona_veterinara.text=""
  @email_veterinara.text=""

end

# Frame za unos životinje
@unos_zivotinja_frame = FXHorizontalFrame.new(self, opts: LAYOUT_FILL_X|LAYOUT_FILL_Y)
@labela_frame_zivotinja = FXVerticalFrame.new(@unos_zivotinja_frame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_SIDE_LEFT)
FXLabel.new(@labela_frame_zivotinja, "Ime:")
FXLabel.new(@labela_frame_zivotinja, "Datum rodenja")
FXLabel.new(@labela_frame_zivotinja, "Spol:")
FXLabel.new(@labela_frame_zivotinja, "Sifra")
FXLabel.new(@labela_frame_zivotinja, "Vrsta: ")
FXLabel.new(@labela_frame_zivotinja, "Pasmina")


@podaci_frame_zivotinja = FXVerticalFrame.new(@unos_zivotinja_frame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_SIDE_RIGHT)
@ime_zivotinje = FXTextField.new(@podaci_frame_zivotinja, 20, opts: LAYOUT_FILL_X)
@datum_rodenja_zivotinje = FXTextField.new(@podaci_frame_zivotinja, 20, opts: LAYOUT_FILL_X)
@spol_zivotinje = FXTextField.new(@podaci_frame_zivotinja, 20, opts: LAYOUT_FILL_X)
@sifra_zivotinje = FXTextField.new(@podaci_frame_zivotinja, 20, opts: LAYOUT_FILL_X)
@vrsta_zivotinje = FXTextField.new(@podaci_frame_zivotinja, 20, opts: LAYOUT_FILL_X)
@pasmina_zivotinje = FXTextField.new(@podaci_frame_zivotinja, 20, opts: LAYOUT_FILL_X)


@tipka_dodaj_zivotinju = FXButton.new(@podaci_frame_zivotinja, "Dodaj zivotinju")

@tipka_dodaj_zivotinju.connect(SEL_COMMAND) do
  self.dodaj_zivotinju(veterinarske_ambulante, @ime_zivotinje.text, @datum_rodenja_zivotinje.text, @spol_zivotinje.text,@sifra_zivotinje.text,@vrsta_zivotinje.text,@pasmina_zivotinje.text)
  @ime_zivotinje.text = ""
  @datum_rodenja_zivotinje.text = ""
  @spol_zivotinje.text = ""
  @sifra_zivotinje.text=""
  @vrsta_zivotinje.text=""
  @pasmina_zivotinje.text=""
end

@ispis_frame = FXHorizontalFrame.new(self, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)

# Frame za prikaz liste
@list_frame = FXVerticalFrame.new(@ispis_frame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)
@bica_list = FXList.new(@list_frame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)

# Frame za prikaz detalja
@detalji_frame_labels = FXVerticalFrame.new(@ispis_frame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_SIDE_RIGHT)
@detalji_ime_label = FXLabel.new(@detalji_frame_labels, "Ime:")
@detalji_prezime_label = FXLabel.new(@detalji_frame_labels, "Prezime:")
@detalji_datum_rodenja_label = FXLabel.new(@detalji_frame_labels, "Datum rođenja:")
@detalji_spol_label = FXLabel.new(@detalji_frame_labels, "Spol:")
@detalji_broj_licence_label = FXLabel.new(@detalji_frame_labels, "Broj licence:")
@detalji_adresa_label = FXLabel.new(@detalji_frame_labels, "Adresa:")
@detalji_broj_telefona_label = FXLabel.new(@detalji_frame_labels, "Broj telefona:")
@detalji_email_label = FXLabel.new(@detalji_frame_labels, "Email:")
@detalji_sifra_label = FXLabel.new(@detalji_frame_labels, "Šifra:")
@detalji_vrsta_label = FXLabel.new(@detalji_frame_labels, "Vrsta:")
@detalji_pasmina_label = FXLabel.new(@detalji_frame_labels, "Pasmina:")

@detalji_frame = FXVerticalFrame.new(@ispis_frame, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_SIDE_RIGHT)
@detalji_ime = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_spol= FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_broj_licence = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_datum_rodenja = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_prezime = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_adresa = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_broj_telefona = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_email = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_sifra = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_vrsta = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)
@detalji_pasmina = FXTextField.new(@detalji_frame, 20, opts: LAYOUT_FILL_X)

# Tipka za ažuriranje podataka
@azuriraj_tipka = FXButton.new(@detalji_frame, "Ažuriraj")

# Funkcija za popunjavanje detalja
def popuni_detalje(objekt)
  if objekt.instance_of?(Veterinar)
    @detalji_ime.text = objekt.get_ime
    @detalji_prezime.text = objekt.get_prezime
    @detalji_datum_rodenja.text = objekt.get_datum_rodenja
    @detalji_spol.text = objekt.get_spol
    @detalji_broj_licence.text = objekt.get_broj_licence
    @detalji_adresa.text = objekt.get_adresa
    @detalji_broj_telefona.text = objekt.get_broj_telefona
    @detalji_email.text = objekt.get_email
    # Sakrij atribute životinje
    sakrij_atribute_zivotinje
  elsif objekt.instance_of?(Zivotinja)
    @detalji_ime.text = objekt.get_ime
    @detalji_datum_rodenja.text = objekt.get_datum_rodenja
    @detalji_spol.text = objekt.get_spol
    @detalji_sifra.text = objekt.get_sifra
    @detalji_vrsta.text = objekt.get_vrsta
    @detalji_pasmina.text = objekt.get_pasmina
    # Sakrij atribute veterinara
    sakrij_atribute_veterinara
  end
end

# Funkcija za sakrivanje atributa životinje
def sakrij_atribute_zivotinje
  @detalji_sifra.hide
  @detalji_vrsta.hide
  @detalji_pasmina.hide
  @detalji_ime.show
  @detalji_prezime.show
  @detalji_datum_rodenja.show
  @detalji_spol.show
  @detalji_broj_licence.show
  @detalji_adresa.show
  @detalji_broj_telefona.show
  @detalji_email.show
end

# Funkcija za sakrivanje atributa veterinara
def sakrij_atribute_veterinara
  @detalji_sifra.show
  @detalji_vrsta.show
  @detalji_pasmina.show
  @detalji_ime.show
  @detalji_prezime.hide
  @detalji_datum_rodenja.show
  @detalji_spol.hide
  @detalji_broj_licence.show
  @detalji_adresa.hide
  @detalji_broj_telefona.hide
  @detalji_email.hide
end

# Poveži događaj na listu
@bica_list.connect(SEL_COMMAND) do
  indeks = @bica_list.currentItem
  if indeks >= 0
    objekt = veterinarske_ambulante[indeks]
    popuni_detalje(objekt)
  end
end

# Poveži događaj na tipku "Ažuriraj"
# Poveži događaj na tipku "Ažuriraj"
@azuriraj_tipka.connect(SEL_COMMAND) do
  indeks = @bica_list.currentItem
  if indeks >= 0
    objekt = veterinarske_ambulante[indeks]
    if objekt.instance_of?(Veterinar)
      # Ažuriranje podataka veterinara
      objekt.set_ime(@detalji_ime.text)
      objekt.set_prezime(@detalji_prezime.text)
      objekt.set_datum_rodenja(@detalji_datum_rodenja.text)
      objekt.set_spol(@detalji_spol.text)
      objekt.set_broj_licence(@detalji_broj_licence.text)
      objekt.set_adresa(@detalji_adresa.text)
      objekt.set_broj_telefona(@detalji_broj_telefona.text)
      objekt.set_email(@detalji_email.text)
    elsif objekt.instance_of?(Zivotinja)
      # Ažuriranje podataka životinje
      objekt.set_ime(@detalji_ime.text)
      objekt.set_datum_rodenja(@detalji_datum_rodenja.text)
      objekt.set_spol(@detalji_spol.text)
      objekt.set_sifra(@detalji_sifra.text)
      objekt.set_vrsta(@detalji_vrsta.text)
      objekt.set_pasmina(@detalji_pasmina.text)
    end
    # Ažuriraj prikaz detalja
    popuni_detalje(objekt)
  end
end






@brisanje_frame = FXVerticalFrame.new(self, opts: LAYOUT_FILL_X | LAYOUT_FILL_Y)
FXLabel.new(@brisanje_frame, "Ime za obrisati:")
@bica_brisanje = FXTextField.new(@brisanje_frame, 20, opts: LAYOUT_FILL_X)
@tipka_brisanje = FXButton.new(@brisanje_frame, "Obrisi")
@tipka_brisanje.connect(SEL_COMMAND) do
  self.brisi(@bica_brisanje.text, veterinarske_ambulante)
  @bica_brisanje.text = ""
end

combo.connect(SEL_COMMAND) do
  case combo.currentItem
    when 0
      @unos_veterinara_frame.show
      @unos_zivotinja_frame.hide
      @ispis_frame.hide
      @brisanje_frame.hide

    when 1
      @unos_veterinara_frame.hide
      @unos_zivotinja_frame.show
      @ispis_frame.hide
      @brisanje_frame.hide

    when 2
      @bica_list.clearItems
      veterinarske_ambulante.each do |bice|
      @bica_list.appendItem(bice.get_ime())
      end
      @unos_veterinara_frame.hide
      @unos_zivotinja_frame.hide
      @ispis_frame.show
      @brisanje_frame.hide
    when 3
      @unos_veterinara_frame.hide
      @unos_zivotinja_frame.hide
      @ispis_frame.hide
      @brisanje_frame.show
    when 4
      self.spremi_podatke(veterinarske_ambulante)
      getApp().stop
  end
  self.recalc
end
end





def create
  super
  show(PLACEMENT_SCREEN)
end
end

FXApp.new do |app|
VeterinarskaAmbulantaApp.new(app)
app.create
app.run
end
