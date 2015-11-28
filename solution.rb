# Model
Item = Struct.new(:name, :sell_in, :quality)

# Base updater
class ItemUpdater
  NORMAL = 1
  NORMAL_PASS = 2

  # should return the new item
  def update_quality(item)
    item.quality = 0 if item.quality < 0
    item.quality = 50 if item.quality > 50
  end
end

# Updaters
class AgedBrieUpdater < ItemUpdater
  def update_quality(item)
    item.sell_in -= 1
    item.quality += (item.sell_in >= 0 ? NORMAL : NORMAL_PASS)
    super(item)
  end
end

class SulfurasUpdater < ItemUpdater
  def update_quality(item)
    # it is legendary
    # it will not increase in quality as time goes on
  end
end

class BackstagePassesUpdater < ItemUpdater
  def update_quality(item)
    if item.sell_in <= 0
      item.quality = 0
    else
      degrade = 1
      sell_in = item.sell_in
      if sell_in <= 5
        degrade = 3
      elsif sell_in <= 10
        degrade = 2
      end
      item.quality += degrade
    end

    # super call
    item.sell_in -= 1
    super(item)
  end
end

class ConjuredUpdater < ItemUpdater
  def update_quality(item)
    item.sell_in -= 1
    item.quality -= (item.sell_in >= 0 ? NORMAL : NORMAL_PASS) * 2
    super(item)
  end
end

class NormalUpdater < ItemUpdater
  def update_quality(item)
    item.sell_in -= 1
    item.quality -= (item.sell_in >= 0 ? NORMAL : NORMAL_PASS)
    super
  end
end

# Factory
class ItemUpdaterFactory
	def create(name)
    NormalUpdater.new if name.nil?

    case
    when name.include?("Aged Brie")
      AgedBrieUpdater.new
    when name.include?("Sulfuras")
      SulfurasUpdater.new
    when name.include?("Backstage passes")
      BackstagePassesUpdater.new
    when name.include?("Conjured")
      ConjuredUpdater.new
    else
      NormalUpdater.new
    end
  end
end

# Handler
def update_quality(items)
  factory = ItemUpdaterFactory.new
  items.each do |item|
    updater = factory.create(item.name)
    item = updater.update_quality(item)
  end
end