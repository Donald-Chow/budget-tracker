require "open-uri"
class ReceiptsController < ApplicationController
  before_action :set_receipt, only: %i[ show edit update destroy ]

  # GET /receipts or /receipts.json
  def index
    @receipts = Receipt.all
  end

  # GET /receipts/1 or /receipts/1.json
  def show
  end

  # GET /receipts/new
  def new
    @receipt = Receipt.new; @receipt.items.build
  end

  # GET /receipts/1/edit
  def edit
  end

  # POST /receipts or /receipts.json
  def create
    @receipt = Receipt.new(receipt_params)
    respond_to do |format|
      if @receipt.save
        format.html { redirect_to @receipt, notice: "Receipt was successfully created." }
        format.json { render :show, status: :created, location: @receipt }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_photo
    @receipt = Receipt.new
  end

  def create_photo
    puts "uploading photo"
    photo = Cloudinary::Uploader.upload(params[:receipt][:photo])
    receipt_photo_url = photo["url"]
    puts "photo uploaded"
    puts "calling chatgpt"
    # https://platform.openai.com/docs/guides/vision?lang=curl
    response = chatgpt.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "user", content: [
            { type: "text", text: receipt_parser_instruction },
            { type: "image_url", image_url: { url: receipt_photo_url, detail: "high" } } ] }
        ] }
      )
    content = response.dig("choices", 0, "message", "content")
    puts "response received"
    puts content

    parsed_receipt = JSON.parse(content)
    puts "see parsed receipt"
    puts parsed_receipt

    puts "creating receipt"
    @receipt = Receipt.new
    @receipt.store = parsed_receipt["store"]
    @receipt.date = parsed_receipt["date"]
    file = URI.open(photo["secure_url"])
    @receipt.photo.attach(io: file, filename: photo["original_filename"], content_type: photo["format"])
    @receipt.save
    parsed_receipt["items"].map do |item_info|
      item = Item.new
      item.receipt = @receipt
      item.name = item_info["name"]
      item.amount = item_info["amount"]

      category = Category.find_by(name: item_info["category"])
      category = Category.create(name: item_info["category"], budget: 0) if category.nil?
      item.category = category
      item.save
    end
    redirect_to receipt_path(@receipt)
    console
  end

  # PATCH/PUT /receipts/1 or /receipts/1.json
  def update
    respond_to do |format|
      if @receipt.update(receipt_params)
        format.html { redirect_to @receipt, notice: "Receipt was successfully updated." }
        format.json { render :show, status: :ok, location: @receipt }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1 or /receipts/1.json
  def destroy
    @receipt.destroy!

    respond_to do |format|
      format.html { redirect_to receipts_path, status: :see_other, notice: "Receipt was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt
      @receipt = Receipt.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def receipt_params
      params.require(:receipt).permit(:store, :date, :photo, items_attributes: %i[id name category_id amount _destroy])
    end

    def chatgpt
      @chatgpt ||= OpenAI::Client.new
    end

    def receipt_parser_instruction
      # multi-line string
      <<~INSTRUCTION
You are a AI assistant for a budget app.
I need you to analyze this receipt and return me a JSON with the receipt information and each item's information translated to ENGLISH.
If the Total in the receipt includes tax, please allocate tax to each item respectively.
the JSON needs to be in the following format and attributes:
{ store: name_of_the_store_on_the_receipt, date: date_of_the_receipt, items: [{name: item_name, category: category_name, amount: item_amount_including_tax}] }
return the JSON as a string only, not a code block and do not add any of your descriptive text
      INSTRUCTION
    end
end
