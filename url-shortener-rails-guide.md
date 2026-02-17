# URL Shortener con Ruby on Rails - Guia de Aprendizaje

Una guia paso a paso para construir un acortador de URLs mientras aprendes Rails.

---

## Fase 0: Preparacion del Entorno

### Instalar Ruby

```bash
# En macOS con Homebrew
brew install rbenv ruby-build
rbenv install 3.3.0
rbenv global 3.3.0

# Verificar instalacion
ruby -v
```

### Instalar Rails

```bash
gem install rails
rails -v
```

### Herramientas adicionales

- Un editor de codigo (VS Code, RubyMine, lo que prefieras)
- PostgreSQL o SQLite (SQLite viene por defecto, suficiente para aprender)
- Git para control de versiones

---

## Fase 1: Crear el Proyecto

```bash
rails new url_shortener
cd url_shortener
```

### Estructura de carpetas importante

```
app/
  controllers/    # Logica de las peticiones HTTP
  models/         # Modelos de datos (ActiveRecord)
  views/          # Plantillas HTML (ERB)
config/
  routes.rb       # Definicion de rutas
db/
  migrate/        # Migraciones de base de datos
```

---

## Fase 2: Modelo de Datos

### Crear el modelo Url

```bash
rails generate model Url original_url:string short_code:string clicks:integer
```

### Editar la migracion (db/migrate/xxx_create_urls.rb)

```ruby
class CreateUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :urls do |t|
      t.string :original_url, null: false
      t.string :short_code, null: false
      t.integer :clicks, default: 0

      t.timestamps
    end

    add_index :urls, :short_code, unique: true
  end
end
```

### Ejecutar la migracion

```bash
rails db:migrate
```

---

## Fase 3: Validaciones y Logica del Modelo

### Editar app/models/url.rb

```ruby
class Url < ApplicationRecord
  validates :original_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :short_code, presence: true, uniqueness: true

  before_validation :generate_short_code, on: :create

  def increment_clicks!
    increment!(:clicks)
  end

  private

  def generate_short_code
    self.short_code ||= SecureRandom.alphanumeric(6)
  end
end
```

---

## Fase 4: Controlador

### Generar el controlador

```bash
rails generate controller Urls
```

### Editar app/controllers/urls_controller.rb

```ruby
class UrlsController < ApplicationController
  def index
    @url = Url.new
    @recent_urls = Url.order(created_at: :desc).limit(10)
  end

  def create
    @url = Url.new(url_params)

    if @url.save
      redirect_to root_path, notice: "URL acortada: #{short_url(@url)}"
    else
      @recent_urls = Url.order(created_at: :desc).limit(10)
      render :index, status: :unprocessable_entity
    end
  end

  def redirect
    @url = Url.find_by!(short_code: params[:short_code])
    @url.increment_clicks!
    redirect_to @url.original_url, allow_other_host: true
  end

  private

  def url_params
    params.require(:url).permit(:original_url)
  end

  def short_url(url)
    "#{request.base_url}/#{url.short_code}"
  end
  helper_method :short_url
end
```

---

## Fase 5: Rutas

### Editar config/routes.rb

```ruby
Rails.application.routes.draw do
  root "urls#index"

  resources :urls, only: [:create]

  get "/:short_code", to: "urls#redirect", as: :short
end
```

---

## Fase 6: Vistas

### Crear app/views/urls/index.html.erb

```erb
<div class="container">
  <h1>URL Shortener</h1>

  <% if notice %>
    <p class="notice"><%= notice %></p>
  <% end %>

  <%= form_with model: @url, local: true do |f| %>
    <% if @url.errors.any? %>
      <div class="errors">
        <% @url.errors.full_messages.each do |message| %>
          <p><%= message %></p>
        <% end %>
      </div>
    <% end %>

    <div class="form-group">
      <%= f.label :original_url, "URL a acortar" %>
      <%= f.url_field :original_url, placeholder: "https://ejemplo.com/una-url-muy-larga", required: true %>
    </div>

    <%= f.submit "Acortar URL" %>
  <% end %>

  <hr>

  <h2>URLs Recientes</h2>
  <table>
    <thead>
      <tr>
        <th>URL Original</th>
        <th>URL Corta</th>
        <th>Clicks</th>
      </tr>
    </thead>
    <tbody>
      <% @recent_urls.each do |url| %>
        <tr>
          <td><%= truncate(url.original_url, length: 50) %></td>
          <td><%= link_to short_url(url), short_url(url) %></td>
          <td><%= url.clicks %></td>
        </tr>
      <% end %>
    </tbody>
  </table>
</div>
```

---

## Fase 7: Ejecutar y Probar

```bash
rails server
```

Visita `http://localhost:3000` en tu navegador.

---

## Fase 8: Mejoras Opcionales (Para Seguir Aprendiendo)

### Nivel 1: Basicas

- [x] Agregar estilos CSS (o usar Tailwind)
- [x] Validar que la URL no sea un ciclo (que no apunte a tu propio dominio)
- [x] Copiar al portapapeles con JavaScript

### Nivel 2: Intermedias

- [x] Autenticacion de usuarios con Devise
- [x] Que cada usuario vea solo sus URLs
- [x] URLs personalizadas (que el usuario elija el short_code)
- [x] Fecha de expiracion para las URLs

### Nivel 3: Avanzadas

- [x] API REST con JSON responses
- [x] Estadisticas detalladas (pais, navegador, referrer)
- [x] Rate limiting para prevenir abuso
- [x] Panel de administracion con ActiveAdmin

### Nivel 4: Produccion

- [ ] Deploy en Render, Fly.io o Railway
- [ ] Configurar PostgreSQL para produccion
- [ ] Agregar dominio personalizado

---

## Comandos Utiles de Rails

```bash
# Consola interactiva de Rails
rails console

# Ver todas las rutas
rails routes

# Ejecutar tests
rails test

# Ver logs en tiempo real
tail -f log/development.log

# Revertir ultima migracion
rails db:rollback

# Crear seed data
rails db:seed
```

---

## Recursos Adicionales

- [Rails Guides](https://guides.rubyonrails.org/)
- [Ruby Style Guide](https://rubystyle.guide/)
- [GoRails](https://gorails.com/)
- [Drifting Ruby](https://www.driftingruby.com/)

---

Creado con propositos educativos. Buena suerte con tu aprendizaje.
