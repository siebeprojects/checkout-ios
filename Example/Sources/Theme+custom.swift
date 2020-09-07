import Optile

extension Theme {
    static var custom: Theme {
        return Theme(
            font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
            backgroundColor: .white,
            tableBorder: .gray,
            tableCellSeparator: .lightGray,
            textColor: .blue,
            detailTextColor: .darkGray,
            buttonTextColor: .white,
            tintColor: .blue,
            errorTextColor: .red
        )
    }
}
