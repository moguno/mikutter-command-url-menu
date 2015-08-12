#encoding: utf-8

Plugin.create(:"mikutter-command-url-menu") {
  def menuitem(menu, url, header)
    item = Gtk::MenuItem.new("【#{header}】#{url}")

    item.ssc(:activate) { |w, e|
      Gtk::openurl(url)
      menu.destroy
    }

    item
  end

  command(:url_menu,
          :name => _("URLメニューを出す"),
          :condition => lambda { |opt| 
            Plugin::Command[:HasMessage] &&
            opt.messages.first[:entities] &&
            [
              [ :entities, :urls ],
              [ :entities, :media ],
              [ :extended_entities, :media ],
            ].any? { |path|
              opt.messages.first[path[0]] && 
              Array(opt.messages.first[path[0]][path[1]]).count != 0
            }
          },
          :visible => false,
          :role => :timeline) { |opt|

    begin
      opt.messages.each { |message|
        menu = nil

        param_urls = { :path => [ :entities, :urls, :expanded_url ], :header => _("Web") }
        param_media = { :path => [ :entities, :media, :media_url ], :header => _("画像") }
        param_extended_media = { :path => [ :extended_entities, :media, :media_url ], :header => _("画像") }

        # URL
        Array(message[param_urls[:path][0]][param_urls[:path][1]]).each { |url|
          menu ||= Gtk::Menu.new

          item = menuitem(menu, url[param_urls[:path][2]], param_urls[:header])
          menu.append(item)
        }

        # 拡張 or 普通のメディア
        target_param_media = if message[param_extended_media[:path][0]]
          param_extended_media
        elsif message[param_media[:path][0]]
          param_media
        end

        if target_param_media
          Array(message[target_param_media[:path][0]][target_param_media[:path][1]]).each { |url|
            menu ||= Gtk::Menu.new

            item = menuitem(menu, url[target_param_media[:path][2]], target_param_media[:header])
            menu.append(item)
          }
        end

        if menu
          menu.show_all
          menu.popup(nil, nil, 3, 0)
        end
      }
    rescue => e
      puts e
      puts e.backtrace
    end
  }
}
