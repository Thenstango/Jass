//! textmacro Array_Common takes name, valueType
	private $name$Table table;
	private integer size;
	
	static method create ()->thistype {
		thistype this = thistype.allocate();
		this.table = $name$Table.create();
		this.size = 0;
		return this;
	}
	
	method destroy () {
		this.table.destroy();
		this.deallocate();
	}
	
	method operator Size ()->integer {
		return this.size;
	}
	
	method operator Size= (integer size) {
		integer i = 0;
		if (size < 0) {
			debug Log.Error("Array.Size=", "the given size (" + I2S(size) + ") must be greater than zero!");
			return;
		} else if (size < this.size) {
			for (i = size; i < this.size; i += 1) {
				this.table.Flush(i);
			}
		}
		this.size = size;
	}
	
	method operator First ()->$dataType$ {
		if (this.size <= 0) {
			return 0;
		}
		return this.table[0];
	}
	
	method operator Last ()->$dataType$ {
		if (this.size <= 0) {
			return 0;
		}
		return this.table[this.size - 1];
	}
	
	method operator Random ()->$dataType$ {
		integer random = 0;
		if (this.size <= 0) {
			return 0;
		}
		random = R2I(Math.Random * this.size);
		return this.table[random];
	}
	
	method GetEnumerator ()->I$name$Enumerator {
		return $name$ArrayEnumerator.create(this.table, this.size);
	}
	
	method operator [] (integer index)->$dataType$ {
		if (index < 0) {
			if (index < -this.size) {
				debug Log.Error("Array.[]", "the given index (" + I2S(index) + ") must be greater than -this.size (" + I2S(this.size) + ")");
				return 0;
			}
			index += this.size;
		}
		return this.table[index];
	}
	
	method operator []= (integer index, $dataType$ value) {
		if (index < 0) {
			if (index < -this.size) {
				debug Log.Error("Array.[]=", "the given index (" + I2S(index) + ") must be greater than -this.size (" + I2S(this.size) + ")");
				return 0;
			}
			index += this.size;
		} else if (index >= this.size) {
			this.size = index + 1;
		}
		this.table[index] = value;
	}
	
	method IsEmpty ()->boolean {
		return this.size <= 0;
	}
	
	method Contains ($dataType$ value)->boolean {
		integer i = 0;
		for (i = 0; i < this.size; i += 1) {
			if (this.table[i] == value) {
				return true;
			}
		}
		return false;
	}
	
	method Clear () {
		this.table.destroy();
		this.table = $name$Table.create();
	}
	
	method Push ($dataType$ value) {
		this.table[this.size] = value;
		this.size += 1;
	}
	
	method Pop ()->$dataType$ {
		$dataType$ value = 0;
		if (this.size > 0) {
			this.size -= 1;
			value = this.table[this.size];
			this.table.Flush(this.size);
		}
		return value;
	}
	
	method Unshift ($dataType$ value) {
		integer i = 0;
		for (i = this.size; i > 0; i -= 1) {
			this.table[i] = this.table[i - 1];
		}
		this.table[0] = value;
		this.size += 1;
	}
	
	method Shift ()->$dataType$ {
		integer i = 0;
		$dataType$ value = 0;
		if (this.size > 0) {
			this.size -= 1;
			value = this.table[0];
			for (i = 0; i < this.size; i += 1) {
				this.table[i] = this.table[i + 1];
			}
			this.table.Flush(i);
		}
		return value;
	}
	
	method Remove ($dataType$ value)->boolean {
		integer i = 0;
		boolean result = false;
		for (i = 0; i < this.size; i += 1) {
			if (result) {
				this.table[i - 1] = this.table[i];
			}
			result = result || this.table[i] == value;
		}
		if (result) {
			this.table.Flush(i - 1);
		}
		return result;
	}
	
	method Reverse () {
		$name$Table table = $name$Table.create();
		integer i = 0;
		for (i = this.size - 1; i >= 0; i -= 1) {
			table[i] = this.table[this.size - i - 1];
		}
		this.table.destroy();
		this.table = table;
	}
    
	method Sort ($name$Comparer comparer) {
		this.quickSort(0, this.size - 1, comparer);
	}
	
	private method quickSort (integer low, integer high, $name$Comparer comparer) {
		if (low >= high) {
			return;
		}
		integer first = low;
		integer last = high;
		$datatype$ key = this.table[first];
		while (first < last) {
			while (first < last && comparer.evaluate(this.table[last], key) >= 0 ) {
				last -= 1;
			}
			this.table[first] = this.table[last];

			while (first < last && comparer.evaluate(this.table[first], key) <= 0) {
				first += 1;
			}
			this.table[last] = this.table[first];
		}
		this.table[first] = key;
		this.quickSort(low, first - 1, comparer);
		this.quickSort(first + 1, high, comparer);
	}
//! endtextmacro

//! textmacro ArrayEnumerator takes name, dataType
private struct $name$ArrayEnumerator extends I$name$Enumerator {
	private $name$Table table;
	private integer size;
	private integer position;
	
	method operator Current ()->$dataType$ {
		if (this.position < 0) {
			return 0;
		}
		return this.table[this.position];
	}
	
	static method create ($name$Table table, integer size) {
		thistype this = thistype.allocate();
		this.table = table;
		this.size = size;
		this.position = -1;
		return this;
	}
	
	method MoveNext ()->boolean {
		this.position += 1;
		if (this.position < this.size) {
			return true;
		}
		this.destroy();
		return false;
	}
	
	method Reset () {
		this.position = -1;
	}
}
//! endtextmacro



