require 'csv'

Spree::Admin::ReportsController.class_eval do
  before_action :add_marketplace_reports, only: [:index]

  def earnings
    @supplier_earnings = get_supplier_earnings
    respond_to do |format|
      format.html
      format.csv { send_data earnings_csv }
    end
  end

  def earnings_csv
    header1 = ["Supplier Earnings"]
    header2 = ["Supplier", "Earnings", "Email"]

    CSV.generate do |csv|
      csv << header1
      csv << []
      csv << header2
      @supplier_earnings.each do |se|
        csv << ["#{se[:name]}", "#{se[:earnings].to_html}", "#{se[:email]}"]
      end
    end
  end

  def missing_suppliers
    @products = Spree::Product.includes(:suppliers).where(spree_suppliers: { id: nil })
    respond_to do |format|
      format.html
      format.csv { send_data earnings_csv }
    end
  end

  private

  def add_marketplace_reports
    marketplace_reports.each do |report|
      Spree::Admin::ReportsController.add_available_report! report
    end
  end

  def marketplace_reports
    [:earnings, :missing_suppliers]
  end

  def get_supplier_earnings
    grouped_supplier_earnings.each do |se|
      se[:earnings] = se[:earnings].inject(Spree::Money.new(0)){ |e, c| c + e }
    end
  end

  def grouped_supplier_earnings
    params[:q] = search_params
    @search = Spree::Order.complete.ransack(params[:q])
    @orders = @search.result

    supplier_earnings_map = @orders.map { |o| o.supplier_earnings_map }
    grouped_suppliers_map = supplier_earnings_map.flatten.group_by { |e| e[:name] }.values
    grouped_earnings = grouped_suppliers_map.map do |gs|
      h = {}
      h[:name] = nil
      h[:email] = nil
      h[:earnings] = []
      gs.each do |s|
        h[:name] = s[:name] if h[:name].nil?
        h[:email] = s[:email] if h[:email].nil?
        h[:earnings] << s[:earnings]
      end
      h
    end
    grouped_earnings
  end

end
