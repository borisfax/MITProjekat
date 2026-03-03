const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Ime je obavezno'],
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'Email je obavezan'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [
        /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
        'Unesite validan email',
      ],
    },
    password: {
      type: String,
      required: [true, 'Lozinka je obavezna'],
      minlength: [6, 'Lozinka mora imati najmanje 6 karaktera'],
      select: false, // Ne vraća password u query-ima po defaultu
    },
    phone: {
      type: String,
      default: '',
    },
    address: {
      type: String,
      default: '',
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
  },
  {
    timestamps: true, // Automatski dodaje createdAt i updatedAt
  }
);

// Hash password pre čuvanja
userSchema.pre('save', async function (next) {
  // Samo ako je password promenjen
  if (!this.isModified('password')) {
    return next();
  }

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Metoda za proveru passworda
userSchema.methods.comparePassword = async function (candidatePassword) {
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw new Error(error);
  }
};

// JSON response - ne vraćaj password
userSchema.methods.toJSON = function () {
  const user = this.toObject();
  delete user.password;
  return user;
};

const User = mongoose.model('User', userSchema);

module.exports = User;
